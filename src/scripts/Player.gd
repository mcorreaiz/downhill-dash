extends KinematicBody2D

onready var sprite: Sprite = $Sprite

slave var slave_position: Vector2 = Vector2()
slave var slave_movement: Vector2 = Vector2()

var facing_right: bool = true

var accel: Vector2 = Vector2.DOWN
var velocity: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.DOWN

const hill_slope: float = PI / 8
const gravity: int = 2000

const MAX_SPEED: int = 500
const MAX_SPEED_MODIFIER = 1.5
const AIR_MAX_SPEED_MODIFIER: float = 0.8
var current_MAX_SPEED: int = MAX_SPEED
const MIN_SPEED_Y: int = 30
const MIN_DIR_Y: float = 0.4

const ROCK_FALLING: float = 0.5
const STUN_TIME: float = 1.5
const STUN_INNMUNITY: float = 1.0
const SPRITE_ANGLE_ROTATION: int = 7
const ICE_MAX_TURN_ANGLE: float = 1.35
const ICE_ACCEL_MULT: float = 1.5
const ICE_FRICT_MULT: float = 0.5
const JUMP_MAX_AIR_TIME: float = 1.0

var stun_rotation_effect: bool = false
var rock_effect: bool = false
var ice_effect: bool = false
var jump_effect: bool = false
var stun_effect: bool = false
var jump_scale_modifier: int = 0

func _ready():
	pass

func init(name, position, is_slave):
	$NameLabel.text = name
	global_position = position

func update_rotation(delta):
	# Hardcoded Sprite anim for rock hit
	if stun_rotation_effect:
		sprite.rotation += delta * SPRITE_ANGLE_ROTATION
		return
	if jump_effect:
		return
	# TODO: refactorear usando angulos
	direction = (get_global_mouse_position() - global_position).normalized()
	direction.y = max(direction.y, MIN_DIR_Y)
	rotation = direction.angle()
	
func update_accel():
	var angle_y_axis = rotation - (PI / 2)
	var turn_angle = clamp(abs(direction.angle_to(velocity)), 0, PI/2)

	var accel_mult = 1 + 2 * (current_MAX_SPEED - velocity.length()) / current_MAX_SPEED
	var frict_mult = 2 - (current_MAX_SPEED - velocity.length()) / current_MAX_SPEED
	if ice_effect:
		accel_mult = accel_mult * ICE_ACCEL_MULT
		frict_mult = frict_mult * ICE_FRICT_MULT

	var dir_accel = Vector2(cos(angle_y_axis), 0).rotated(direction.angle()) * accel_mult
	var dir_friction = Vector2(sin(turn_angle), 0).rotated(velocity.angle()) * frict_mult
	
	accel = (dir_accel - dir_friction) * sin(hill_slope) * gravity
	return turn_angle
	
func update_velocity(delta):
	velocity += accel * delta
	
	#Velocidad máxima
	velocity = velocity.clamped(current_MAX_SPEED)
	velocity.y = max(velocity.y, MIN_SPEED_Y)

func apply_modifiers(delta, turn_angle):
	#Rock effect stuns player after falling
	if stun_effect:
		velocity = Vector2(0, 0)
	if ice_effect:
		if turn_angle > ICE_MAX_TURN_ANGLE:
			_on_rock_collision()
	if jump_effect:
		sprite.scale += Vector2(delta * jump_scale_modifier, delta * jump_scale_modifier) 
		sprite.rotation = (get_global_mouse_position() - global_position).normalized().angle()
		sprite.rotation -= PI/2
		
func _physics_process(delta) -> void:
	Globals.race_time += delta
		
	if is_network_master():
		update_rotation(delta)
		var turn_angle = update_accel()
		update_velocity(delta)
		apply_modifiers(delta, turn_angle)

		#Movimiento
		velocity = move_and_slide(velocity)
		
		#Voltear sprite
		if !facing_right and (rotation < PI/2) and (rotation > -PI/2):
			flip()

	else:
		pass
		# Ver como manejar el movimiento de los 'slaves'
		
	
	if position.y > get_node("../Game/FinishLine").position.y:
		Network.close()
		emit_signal('server_disconnected')
		get_tree().change_scene('res://scenes/EndRace.tscn')
		queue_free()

	if get_tree().is_network_server():
		Network.update_position(int(name), position)
	
func _on_rock_collision() -> void:
	# Needs to trigger a sound as feedback
	# First timer its the "falling" animation, second its the stuntime, third its innmunity
	stun_rotation_effect = true #Player can't turn
	yield(get_tree().create_timer(ROCK_FALLING), "timeout")
	object_stun()
	
func _on_ice_enter() -> void:
	# Needs to trigger an animation and a sound as feedback
	current_MAX_SPEED = MAX_SPEED * MAX_SPEED_MODIFIER
	ice_effect = true #Player speed increased, if too much rotation will fall

func _on_ice_exit() -> void:
	current_MAX_SPEED = MAX_SPEED
	ice_effect = false 

func _on_jump_exit() -> void:
	# Needs to trigger a sound as feedback
	var jump_time = JUMP_MAX_AIR_TIME*velocity.length()/current_MAX_SPEED
	set_collision_mask_bit(2, false) #Air, can't collide
	current_MAX_SPEED = MAX_SPEED * AIR_MAX_SPEED_MODIFIER
	jump_effect = true
	jump_scale_modifier = 1
	yield(get_tree().create_timer(jump_time/2), "timeout") # Timer for "jupming" animation
	jump_scale_modifier = -1
	yield(get_tree().create_timer(jump_time/2), "timeout") # Timer for "falling" animation
	set_collision_mask_bit(2, true) # Grounded, can collide again	
	current_MAX_SPEED = MAX_SPEED
	jump_effect = false
	var dir = (get_global_mouse_position() - global_position).normalized()
	if dir.y < MIN_DIR_Y:
		stun_rotation_effect = true
		object_stun()
	sprite.rotation = 0

func object_stun() -> void:
	stun_effect = true #Player can't move
	set_collision_mask_bit(2, false) # Player can't collide objects
	yield(get_tree().create_timer(STUN_TIME), "timeout")
	stun_effect = false #Player can move
	stun_rotation_effect = false # Stop spinning
	sprite.rotation = 0
	yield(get_tree().create_timer(STUN_INNMUNITY), "timeout")
	set_collision_mask_bit(2, true) #Player can collide objects

func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
