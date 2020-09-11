extends KinematicBody2D

const GRAVITY: int = 350
const MOVE_SPEED: int = 400
const MAX_FALL_SPEED: int = 1000

onready var sprite: Sprite = $Sprite
onready var text_accel: Label = $Label
onready var text_speed: Label = $Label2

slave var slave_position = Vector2()
slave var slave_movement = Vector2()

var y_vel: int = 0
var facing_right: bool = true

func init(name, position, is_slave):
	$NameLabel.text = name
	global_position = position

func _physics_process(delta) -> void:
	var accel := Input.get_accelerometer().normalized()	
	text_accel.text = String(accel)
	text_speed.text = String(y_vel)
	
	print(delta, position)
	
	if is_network_master():
		y_vel += GRAVITY * delta
		if is_on_floor():
			y_vel = 0
	
		if y_vel > MAX_FALL_SPEED:
			y_vel = MAX_FALL_SPEED
		
		var move_dir: int = 0
		if Input.is_action_pressed("move_left") or accel.x < 0:
			move_dir -= 1
		if Input.is_action_pressed("move_right") or accel.x > 0:
			move_dir += 1
			
		var move_direction = Vector2(move_dir * MOVE_SPEED, y_vel)
		move_and_slide(move_direction, Vector2.UP)
		rset_unreliable('slave_position', position)
		rset('slave_movement', move_direction)
		if facing_right and move_dir < -0.05:
			flip()
		if !facing_right and move_dir > 0.05:
			flip()
			
	else:
		move_and_slide(slave_movement)
		position = slave_position
	
	if position.y > 1280:
		get_tree().change_scene('res://scenes/Menu.tscn')
		queue_free()
		
	if get_tree().is_network_server():
		Network.update_position(int(name), position)

func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
