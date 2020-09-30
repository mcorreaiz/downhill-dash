extends Control

var _player_name = ""

func _on_NameField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)

"""
func _load_game():
	get_tree().change_scene("res://scenes/Game.tscn")
	queue_free()
"""
