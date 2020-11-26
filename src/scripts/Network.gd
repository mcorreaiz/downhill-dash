# Este script está cargado en "Autoload" dentro la configuración del proyecto

extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 6
const SERVER_ID = 1
const track_format = "/users/%s/tracks/%s"

var network_peer = NetworkedMultiplayerENet.new()
var network_id = -1
var track_path = ""
var players = {}
var times = []
var self_data = {
	name="",
	position=Vector2(300, 100),
	is_slave=false
}

signal notify_lobby

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func test_create_server():
	return network_peer.create_server(DEFAULT_PORT, MAX_PLAYERS) == OK

func setup_server(player_nickname, track_owner, track_name):
	# Note: server is already created because test_create_server() was called
	self_data.name = player_nickname
	track_path = track_format % [track_owner, track_name]
	players[SERVER_ID] = self_data
	get_tree().set_network_peer(network_peer)
	network_id = get_tree().get_network_unique_id()

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	network_peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(network_peer)
	network_id = get_tree().get_network_unique_id()

func _connected_to_server():
	players[network_id] = self_data
	# Send my data to the server
	rpc_id(SERVER_ID, '_receive_player_info', network_id, self_data)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	if connected_player_id != SERVER_ID:
		# If new player connnects, send my info
		rpc_id(connected_player_id, '_receive_player_info', network_id, self_data)

remote func _receive_player_info(id, info, track_url=track_path):
	var is_server = get_tree().is_network_server()
	players[id] = info
	players[id].is_slave = (id != network_id)
	track_path = track_url
	if is_server:
		# Server notifies everyone of the newcomer
		rpc('_receive_player_info', id, info, track_path)
		
	emit_signal("notify_lobby")
	
	if players.size() == MAX_PLAYERS and is_server:
		start_game()

func start_game():
	rpc("_download_track")

sync func _download_track():
	var http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_track_downloaded")
	get_tree().get_root().add_child(http)
	var error = Firebase.get_document(track_path, http)
	
func _on_track_downloaded(result, response_code, headers, body):
	var track = parse_json(body.get_string_from_utf8())
	var track_content = track.fields.file.stringValue
	var file = File.new()
	while file.open(tmp_track_name(), File.WRITE) != 0:
		pass
	file.store_string(track_content)
	file.close()
	
	pre_configure_game()
	
func pre_configure_game():
	# Load game
	# var game = load(tmp_track_name()).instance()
	var game = load("test.tscn").instance()
	game.set_name("Game")
	var game_script = load("scripts/Game.gd")
	game.set_script(game_script)
	
	get_tree().get_root().add_child(game)
	get_tree().set_current_scene(game)
	
	# Remove menu
	var menu = get_tree().get_root().get_node("Control")
	menu.call_deferred("free")
	get_tree().get_root().remove_child(menu)

	# Tell server that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(SERVER_ID, "done_preconfiguring")
	
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

func get_player_names():
	var names = []
	for p in players.values():
		names.append(p.name)
	return names
	
func tmp_track_name():
	return "res://tmp/Track-%d.tscn" % network_id
