extends Control

var _player_name = ""

onready var CreateButton = $VBoxContainer/CreateButton
onready var StartButton = $StartButton

func _on_NameField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	
	CreateButton.disabled = true
	CreateButton.text = "Hay 1 jugador en tu juego"
	StartButton.visible = true

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)

func _on_StartButton_pressed():
	Network.start_game()

"""
func _load_game():
	get_tree().change_scene("res://scenes/Game.tscn")
	queue_free()
"""
