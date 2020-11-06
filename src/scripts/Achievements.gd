extends Control

const ACHIEVEMENTS_TEXT = {
	firstCoin = "Gana tu primera moneda",
	firstPlace = "Gana tu primera carrera",
	creator = "Crea tu primera pista",
	comeback = "Volver a jugar",
	login = "Recibe tu primera recompensa diaria",
	rich = "Eres rico, tienes más de 500 de oro",
	addFriend = "Añade a un amigo",
	secret = "Secretooo...",
	unlocked = "No está desloqueado"
}

var ach_label
var achievements_textures: Array 

func _ready():
	ach_label = get_node("TextureRect/Panel/AchievementLabel")
	achievements_textures = get_node("TextureRect/Panel/GridContainer").get_children()
	
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_set_self_achievements")
	Firebase.get_document("/users/" + Globals.PLAYER_NAME, http)

func _achievement_set_text(key):
	ach_label.text = "Sala de trofeos\n" + ACHIEVEMENTS_TEXT[key]

func _set_self_achievements(results, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	var achievements_dict = response.fields.achievements.mapValue.fields
	print(achievements_dict)
	for key in achievements_dict:
		var textureButton = get_node("TextureRect/Panel/GridContainer/" + key)
		if achievements_dict[key].booleanValue:
			var stream_texture = load('res://assets/sprites/' + key +'.png')
			var image_texture = ImageTexture.new()
			var image = stream_texture.get_data()
			image.lock() # so i can modify pixel data
			image_texture.create_from_image(image, 0)
			textureButton.texture_normal = image_texture
			textureButton.connect("pressed", self, "_achievement_set_text", [key])
		else:
			textureButton.connect("pressed", self, "_achievement_set_text", ['unlocked'])

func _on_backButton_pressed():
	get_node(".").visible = false

