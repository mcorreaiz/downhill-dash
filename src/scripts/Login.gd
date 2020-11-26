extends Control


var http: HTTPRequest
var config: ConfigFile
var playerName: String

func _ready():
	http = $HTTPRequest
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK && config.has_section_key("user", "playerName"):
		playerName = config.get_value("user","playerName")
		Firebase.login(playerName, http)
	else:
		$LoadingScreen.visible = false
	

func _on_LoginButton_pressed():
	playerName = $NameEdit.text
	Firebase.login($NameEdit.text, http)
	config.set_value("user", "playerName", $NameEdit.text)
	config.save("user://settings.cfg")
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var user = parse_json(body.get_string_from_utf8())
	Firebase.user = user
	Firebase.user.name = playerName
	Rewards.check_daily(user.name)
	if !user.achievements.login: # Add achievement for the first login
		Rewards.add_achievement(user.name, "login")
	# Go to base
	get_tree().change_scene("res://scenes/Base.tscn")
	queue_free()

func _on_NameEdit_text_changed(name):
	var isEmpty = name == ""
	$LoginButton.disabled = isEmpty
