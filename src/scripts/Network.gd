# Este script está cargado en "Autoload" dentro la configuración del proyecto

extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 6
const track_format = "/users/%s/tracks/%s"

var track_path = ""
var players = {}
var times = []
var self_data = {name="", position=Vector2(300, 100), is_slave=false}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(player_nickname, track_owner, track_name):
	self_data.name = player_nickname
	track_path = track_format % [track_owner, track_name]
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	players[local_player_id] = self_data
	rpc('_send_player_info', local_player_id, self_data)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	print(players)
	var local_player_id = get_tree().get_network_unique_id()
	if not (get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)

remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server():
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id])

# A function to be used if needed. The purpose is to request all players in the current session.
remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for peer_id in players:
			if (peer_id != request_from_id):
				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])

remote func _send_player_info(id, info):
	players[id] = info
	players[id].is_slave = true
	if players.size() == MAX_PLAYERS and get_tree().is_network_server():
		start_game()

func start_game():
	rpc("_download_track")

sync func _download_track():
	var http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_track_downloaded")
	get_tree().get_root().add_child(http)
	Firebase.get_document(track_path, http)
	
func _on_track_downloaded(result, response_code, headers, body):
	var track = parse_json(body.get_string_from_utf8())
	var track_content = track.fields.file.stringValue
	var file = File.new()
	file.open("res://tmp/Track.tscn", File.WRITE)
	file.store_string(track_content)
	file.close()
	
	pre_configure_game()
	
func pre_configure_game():
	# Load game
	var game = load("res://tmp/Track.tscn").instance()
	get_tree().get_root().add_child(game)
	get_tree().set_current_scene(game)
	game.load_players(players)
	
	# Remove menu
	var menu = get_tree().get_root().get_node("Control")
	get_tree().get_root().remove_child(menu)
	menu.call_deferred("free")

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")
	
remote func done_preconfiguring():
	print("Iniciar juego")
	
func update_position(id, position, frame, sprite_rotation, sprite_scale):
	players[id].position = position
	players[id].instance.on_slave_update(position, frame, sprite_rotation, sprite_scale)
	
func notify_finish(id, time):
	rpc('_update_time', id, time)
	
sync func _update_time(id, time):
	var is_self = id == get_tree().get_network_unique_id()
	times.append( { time=time, name=players[id].name, is_self=is_self } )
	
	if times.size() == players.size():
		# Load end
		var end_race = preload("res://scenes/EndRace.tscn").instance()
		end_race.results = times
		get_tree().get_root().add_child(end_race)
		get_tree().set_current_scene(end_race)
		
		# Remove game
		var game = get_tree().get_root().get_node("Game")
		get_tree().get_root().remove_child(game)
		game.call_deferred("free")
		
func close_connections():
	get_tree().set_network_peer(null)
	players.clear()
	times.clear()
	
func close():
	players.clear()
	self_data = { name="", position = Vector2(300, 100) }
	get_tree().get_network_peer().close_connection()
