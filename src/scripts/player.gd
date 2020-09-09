extends KinematicBody2D


const GRAVITY: int = 350
const MOVE_SPEED: int = 400
const MAX_FALL_SPEED: int = 1000

onready var sprite: Sprite = $Sprite
onready var text_accel: Label = $Label
onready var text_speed: Label = $Label2

var y_vel: int = 0
var facing_right: bool = true


func _physics_process(delta) -> void:
	var accel := Input.get_accelerometer().normalized()
	var move_dir: int = 0
	
	text_accel.text = String(accel)
	text_speed.text = String(y_vel)
	
	if Input.is_action_pressed("move_left") or accel.x < 0:
		move_dir -= 1
	if Input.is_action_pressed("move_right") or accel.x > 0:
		move_dir += 1
	move_and_slide(Vector2(move_dir * MOVE_SPEED, y_vel), Vector2.UP)

	if is_on_floor():
		y_vel = 55
	y_vel += GRAVITY * delta
	
	if y_vel > MAX_FALL_SPEED:
		y_vel = MAX_FALL_SPEED
		
	if facing_right and move_dir < -0.05:
		flip()
	if !facing_right and move_dir > 0.05:
		flip()
	
	if position.y > 1110:
		get_tree().reload_current_scene()

func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
