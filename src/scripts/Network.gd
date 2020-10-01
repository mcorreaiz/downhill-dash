# Este script está cargado en "Autoload" dentro la configuración del proyecto

extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 2

var players = {}
var self_data = { name="", position = Vector2(300, 100)}

signal player_disconnected
signal server_disconnected

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(player_nickname):
	self_data.name = player_nickname
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
	# TODO: Remove player from game scene
	players.erase(id)

func _on_player_connected(connected_player_id):
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
	if players.size() == MAX_PLAYERS:
		pre_configure_game()

func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()

	# Load world
	get_tree().change_scene("res://scenes/Game.tscn")

	# Load players
	for p in players:
		players[p].instance = preload("res://scenes/Player.tscn").instance()
		var data = players[p]
		var is_slave = p != selfPeerID
		data.instance.set_network_master(p)
		get_tree().get_root().add_child(data.instance)
		data.instance.init(p, data.name, data.position, is_slave)
		
		# Esto no supe como hacerlo de otra forma
		if not is_slave:
			var camera = preload("res://scenes/PlayerCamera.tscn").instance()
			data.instance.add_child(camera)
		

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")
	
remote func done_preconfiguring():
	print("Iniciar juego")
	
func update_position(id, position, rotation):
	players[id].position = position
	players[id].instance.on_slave_update(position, rotation)
	
func close():
	players.clear()
	self_data = { name="", position = Vector2(300, 100) }
	get_tree().get_network_peer().close_connection()
