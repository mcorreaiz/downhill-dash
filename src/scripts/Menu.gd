extends Control

onready var CreateButton = $VBoxContainer/CreateButton
onready var StartButton = $StartButton

func _on_CreateButton_pressed():
	Network.create_server(Firebase.user.name)
	
	CreateButton.disabled = true
	CreateButton.text = "Hay 1 jugador en tu juego"
	StartButton.visible = true

func _on_JoinButton_pressed():
	Network.connect_to_server(Firebase.user.name)

func _on_StartButton_pressed():
	Network.start_game()

"""
func _load_game():
	get_tree().change_scene("res://scenes/Game.tscn")
	queue_free()
"""
