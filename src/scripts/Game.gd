extends Node2D

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
  
func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://scenes/Base.tscn')
	queue_free()

func load_players(players):
	players = players
	for p in players:
		players[p].instance = preload("res://scenes/Player.tscn").instance()
		
		var data = players[p]
		data.instance.set_network_master(p)
		data.instance.init(p, data.name, data.position, data.is_slave)
		connect_rock_collision(data.instance)
		add_child(data.instance)
		
		# Esto no supe como hacerlo de otra forma
		if not data.is_slave:
			var camera = preload("res://scenes/PlayerCamera.tscn").instance()
			data.instance.add_child(camera)
	  
func connect_rock_collision(player):
	var rock_group = get_tree().get_nodes_in_group("Rocks")
	for rock in rock_group:
		rock.connect("rock_collision", player, "_on_rock_collision")
	var ice_group = get_tree().get_nodes_in_group("Ices")
	for ice in ice_group:
		ice.connect("ice_enter", player, "_on_ice_enter")
		ice.connect("ice_exit", player, "_on_ice_exit")
	var jump_group = get_tree().get_nodes_in_group("Jumps")
	for jump in jump_group:
		jump.connect("jump_exit", player, "_on_jump_exit")
