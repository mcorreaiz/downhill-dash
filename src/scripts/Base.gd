extends Control

onready var http: HTTPRequest = $HTTPRequest
var achievements_scene = preload("res://scenes/Achievements.tscn")

func _on_GameLobbyButton_pressed():
	# Go to game lobby menu
	get_tree().change_scene("res://scenes/Menu.tscn")
	queue_free()

func _ready():
	var path = "/users/juanito"
	var fields = {
		"tracks": {
			"arrayValue": {
				"values": [
					{
						"stringValue": "/juanito/primera-pista"
					}
				]
			}
		},
		"times": {
			"mapValue": {
				"fields": {
					"/juanito/primera-pista": {
						"doubleValue": 27.2
					}
				}
			}
		}
	}
	# Firebase.save_document(path, fields, http)
	Firebase.get_document("/users/juanito", http)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print(response)
	
func _on_EditorButton_pressed():
	# Go to level editor
	get_tree().change_scene("res://scenes/Editor.tscn")
	queue_free()

func _on_Achievements_pressed():
	get_node("Achievements").visible = true

func _on_Settings_pressed():
	pass # Replace with function body.
