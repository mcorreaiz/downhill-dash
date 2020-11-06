extends Control

func _on_GameLobbyButton_pressed():
	# Go to game lobby menu
	get_tree().change_scene("res://scenes/Menu.tscn")
	queue_free()
	
func _on_EditorButton_pressed():
	# Go to level editor
	get_tree().change_scene("res://scenes/Editor.tscn")
	queue_free()
