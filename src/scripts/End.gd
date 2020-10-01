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
	return player.name + "'s time was: " + str(player.time) + " seconds"
	
func _get_result():
	if my_player.time < opponent.time:
		return "YOU WON! :)"
	else:
		return "YOU LOSE :("
	
func go_to_main() -> void:
	get_tree().change_scene("res://scenes/Base.tscn")
	queue_free()
