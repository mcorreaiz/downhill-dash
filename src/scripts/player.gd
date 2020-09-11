extends KinematicBody2D

onready var sprite: Sprite = $Sprite
onready var text_accel: Label = $Label
onready var text_speed: Label = $Label2

#var y_vel: int = 0
var facing_right: bool = true
var frozen: bool = false

var velocity = Vector2()

export (int) var speed = 10
export (int) var inertia = 30

const MAX_SPEED: int = 1000


func get_input():
	look_at(get_global_mouse_position())
	
	velocity = Vector2()
	velocity = Vector2(speed, 0).rotated(rotation)
	
	text_speed.text = String(rotation)
	
	#La inercia se define en base al ángulo
	if rotation > 0:
		inertia = 30 * abs(sin(rotation))
	else:
		inertia = 0


func _physics_process(delta) -> void:
	get_input()

	#Movimiento
	#if !frozen:
	velocity = move_and_slide(velocity * inertia) 
	
	#Velocidad máxima
	if velocity.y  > MAX_SPEED:
		velocity.y  = MAX_SPEED
	
	#Voltear sprite
	if !facing_right  and (rotation < PI/2) and (rotation > -1*PI/2):
		flip()
	
	#Chequeo de colisión		
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		print("I collided with ", collision.collider.name)
		#get_tree().reload_current_scene()
		frozen = true
	
	#Reiniciar nivel
	if position.y > 1110:
		get_tree().reload_current_scene()
	
	
func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
