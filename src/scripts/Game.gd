extends Node2D

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://scenes/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	get_tree().get_root().add_child(new_player) # Quizas se debiera hacer con call_deferred()
	var info = Network.self_data
	new_player.init(info.name, info.position, false)
	
	#Connect rock collision signal to player
	var rock_group = get_tree().get_nodes_in_group("Rocks")
	for rock in rock_group:
		rock.connect("rock_collision", new_player, "_on_rock_collision")
		print("rock", rock)


func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://scenes/Base.tscn')
	queue_free()
