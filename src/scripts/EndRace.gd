extends Control

var timer: Timer = Timer.new()

var my_player
var opponent

func _ready():
	#Timer para ejecutar cambio de escena
	timer.set_wait_time(5)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	yield(timer, "timeout")
	go_to_main()
	
func set_results(players):
	_set_players(players)
	
	$MyTimeLabel.text = _get_time_label(my_player)
	if opponent: 
		$OpponentTimeLabel.text = _get_time_label(opponent)
		
	$ResultLabel.text = _get_result()
	
func _set_players(players):
	for p in players:
		var player = players[p]
		if player.is_self:
			my_player = player
		else:
			opponent = player
	
func _get_time_label(player):
	return "El tiempo de {0} fue de:\n{1} segundos".format([player.name, str(player.time)])
	
func _get_result():
	if opponent and opponent.time < my_player.time:
		return "DERROTA :("
	else:
		return "VICTORIA :)"
	
func go_to_main() -> void:
	Network.close_connections()
	get_tree().change_scene("res://scenes/Base.tscn")
	queue_free()