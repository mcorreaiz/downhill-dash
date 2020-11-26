extends Control

var muted: bool = false

func _on_MuteButton_pressed():
	if muted:
		$Panel/GridContainer/MuteButton.texture_normal = load('res://assets/sprites/speaker.png')		
		muted = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)   
	else:
		muted = true
		$Panel/GridContainer/MuteButton.texture_normal = load('res://assets/sprites/mute.png')
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)   

func _on_LogoutButton_pressed():
	$ConfirmationDialog.popup()

func _on_CloseButton_pressed():
	get_node(".").visible = false

func _on_ConfirmationDialog_confirmed():
	var config := ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		config.erase_section_key("user", "playerName")
		config.save("user://settings.cfg")
		get_tree().change_scene("res://scenes/Login.tscn")
		queue_free()
