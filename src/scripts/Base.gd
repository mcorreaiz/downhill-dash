extends Control


func _on_GameLobbyButton_pressed():
	# Go to game lobby menu
	get_tree().change_scene("res://scenes/Menu.tscn")
	queue_free()
