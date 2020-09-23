extends Control

var timer: Timer = Timer.new()

func _ready():
	#Timer para ejecutar cambio de escena
	$TimeLabel.text += str(Globals.race_time) + " seconds"
	timer.set_wait_time(5)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	yield(timer, "timeout")
	go_to_main()
	
func go_to_main() -> void:
	get_tree().change_scene("res://scenes/Base.tscn")
	queue_free()
