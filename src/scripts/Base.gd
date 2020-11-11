extends Control

onready var http: HTTPRequest = $HTTPRequest

func _on_GameLobbyButton_pressed():
	Firebase.login($NameEdit.text, http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var user = parse_json(body.get_string_from_utf8())
	Firebase.user = user
	Firebase.user.name = $NameEdit.text

	# Go to game lobby menu
	get_tree().change_scene("res://scenes/Menu.tscn")
	queue_free()

func _on_NameEdit_text_changed(name):
	var isEmpty = name == ""
	$GameLobbyButton.disabled = isEmpty
	$EditorButton.disabled = isEmpty

func _on_EditorButton_pressed():
	# Go to level editor
	get_tree().change_scene("res://scenes/Editor.tscn")
	queue_free()
