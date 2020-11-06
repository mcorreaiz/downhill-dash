extends "Rewards.gd"

var positions: Array
var names: Array
var times: Array
var results: Array
var coins: Array
var self_time: float
var self_position: int

func _ready():
	$Title.text = "FIN DE CARRERA"
	$Title.modulate.a = 2
	positions = get_node("Positions").get_children()
	names = get_node("Names").get_children()
	times = get_node("Times").get_children()
	coins = get_node("Coins").get_children()
	set_results(results)
	yield(get_tree().create_timer(10.0), "timeout")
	go_to_main()

func set_results(results):
	for i in range(results.size()):
		names[i].text = results[i].name
		times[i].text = String(results[i].time)
		if results[i].is_self:
			names[i].modulate.a = 2
			times[i].modulate.a = 2
			names[i].add_child(background_highlight())
			times[i].add_child(background_highlight())
			positions[i].add_child(background_highlight())
			coins[i].add_child(add_coin_sprite())
			self_position = i + 1
			self_time = results[i].time
			var doc_path = '/users/' + Firebase.user.name
			var http = HTTPRequest.new()
			add_child(http)
			http.connect("request_completed", self,"_give_rewards")
			Firebase.get_document(doc_path, http)

func _give_rewards(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	var earned_coins: int = int(REWARDS_TABLE[Globals.race_bet][self_position-1])
	var current_coins: int = int(response.fields.coins.integerValue)

	coins[self_position-1].text = String(earned_coins)
	add_coins(Firebase.user.name, Globals.race_bet, self_position)

	#esto esta muy feo pero debería funcionar
	var new_tier = 1
	if  current_coins+ earned_coins >= 25:
		new_tier = new_tier + 1
	if current_coins + earned_coins >= 180:
		new_tier = new_tier + 1
	if int(response.fields.tier.integerValue) != new_tier:
		change_tier(Firebase.user.name, new_tier)
	# cambiar tiempo si es mejor que el anterior
	var old_times = response.fields.times.mapValue
	if not old_times or self_time < float(old_times.fields[Globals.track_owner].mapValue.fields[Globals.track_name].values()[0]):
		change_track_time(Firebase.user.name, Globals.track_owner, Globals.track_name, self_time)
	# actualizar cada uno de los achievements desbloqueados
	achievement_checker(response.fields.achievements)


func background_highlight():
	var background = ColorRect.new()
	background.color = Color8(90, 90, 90, 120)
	background.anchor_right = 1
	background.anchor_bottom = 1
	background.show_behind_parent = true
	return background

func add_coin_sprite():
	var coin_sprite = Sprite.new()
	var stream_texture = load('res://assets/sprites/firstCoin.png')
	var image_texture = ImageTexture.new()
	var image = stream_texture.get_data()
	image.lock() # so i can modify pixel data
	image_texture.create_from_image(image, 0)
	coin_sprite.texture = image_texture
	coin_sprite.scale.x = 0.1
	coin_sprite.scale.y = 0.1
	coin_sprite.position.x = 32.0
	coin_sprite.position.y = 15.0
	coin_sprite.show_behind_parent = true
	coin_sprite.centered = false
	return coin_sprite

func go_to_main() -> void:
	Network.close_connections()
	get_tree().change_scene("res://scenes/Base.tscn")
	queue_free()
