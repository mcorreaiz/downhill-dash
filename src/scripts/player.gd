extends KinematicBody2D

onready var sprite: Sprite = $Sprite
onready var text_accel: Label = $Label
onready var text_speed: Label = $Label2

slave var slave_position = Vector2()
slave var slave_movement = Vector2()

var y_vel: int = 0

var facing_right: bool = true
var frozen: bool = false

var accel = Vector2()
var velocity = Vector2()

export (int) var speed = 10
export (int) var inertia = 30

const MAX_SPEED: int = 1000


func get_input():
	look_at(get_global_mouse_position())
	
	var ski_accel = Vector2(30, 0).rotated(rotation)
	var hill_accel = Vector2(0, abs(sin(rotation)) * 20)
	text_speed.text = String(rotation)
	
	accel = ski_accel + hill_accel
	
	#La inercia se define en base al ángulo
	"""
	if rotation > 0:
		inertia = 30 * abs(sin(rotation))
	else:
		inertia = 0
 	"""
	
func init(name, position, is_slave):
	$NameLabel.text = name
	global_position = position


func _physics_process(delta) -> void:
	var accel := Input.get_accelerometer().normalized()	
	text_accel.text = String(accel)
	text_speed.text = String(y_vel)
	
	if is_network_master():
		get_input()

		#Movimiento
		#if !frozen:
		velocity += accel
		# Roce
		velocity *= 0.9
		
		velocity = move_and_slide(velocity) 
		
		#Velocidad máxima
		if velocity.y > MAX_SPEED:
			velocity.y = MAX_SPEED
		
		#Voltear sprite
		if !facing_right  and (rotation < PI/2) and (rotation > -1*PI/2):
			flip()
		
		#Chequeo de colisión		
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			print("I collided with ", collision.collider.name)
			#get_tree().reload_current_scene()
			frozen = true
			
	else:
		pass
		# Ver como manejar el movimiento de los 'slaves'
		
	
	if position.y > 1280:
		Network.close()
		emit_signal('server_disconnected')		
		get_tree().change_scene('res://scenes/EndRace.tscn')
		queue_free()

	if get_tree().is_network_server():
		Network.update_position(int(name), position)	
	


func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
