extends KinematicBody2D

onready var sprite: AnimatedSprite = $Sprite
var os_name: String = OS.get_name()

var player_id
var finished: bool = false
var race_time: float = 0

var facing_right: bool = true

var accel: Vector2 = Vector2.DOWN
var velocity: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.DOWN
var accelerometer: Vector3

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
const ACCLR_READ_ADJUST: float = 0.35

var stun_rotation_effect: bool = false
var rock_effect: bool = false
var ice_effect: bool = false
var jump_effect: bool = false
var stun_effect: bool = false
var jump_scale_modifier: int = 0
var sound_effect_playing: bool = false

remote var slave_position: Vector2 = Vector2(0, 0)

func init(id, name, position, is_slave):
	$NameLabel.text = name
	$NameLabel.add_color_override("font_color", Color(0,0,0,1))
	global_position = position
	player_id = id

func playCurveSound():
	pass
	$CurveSound.play()

func update_animation_frame():
	var frame_count = sprite.frames.get_frame_count("default")
	var frame_idx = (PI - direction.angle()) * frame_count / PI
	sprite.set_frame(frame_idx)

func update_direction(delta):
	# Hardcoded Sprite anim for rock hit
	if stun_rotation_effect:
		sprite.rotation += delta * SPRITE_ANGLE_ROTATION
		return
	if jump_effect:
		return
		
	# TODO: refactorear usando angulos
	if os_name == "Android" or os_name == "iOS":
		var acclr_read = Input.get_accelerometer().normalized()
		accelerometer += ACCLR_READ_ADJUST * (acclr_read - accelerometer)
		direction = Vector2(sin(accelerometer.x*PI/2),
								max(abs(cos(accelerometer.x*PI/2)), MIN_DIR_Y))
		rotation = direction.angle()
		return
	direction = (get_global_mouse_position() - global_position).normalized()
	direction.y = max(direction.y, MIN_DIR_Y)
	rotation = direction.angle()

func update_accel():
	var angle_y_axis = direction.angle() - (PI / 2)
	var turn_angle = clamp(abs(direction.angle_to(velocity)), 0, PI/2)

	#Sound effect when there is sudden change of direction
	if sound_effect_playing == false:
		if (turn_angle < PI/20) or (turn_angle > 4*PI/20) :
			sound_effect_playing = true
			playCurveSound()


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

	# Velocidad máxima
	velocity = velocity.clamped(current_MAX_SPEED)
	velocity.y = max(velocity.y, MIN_SPEED_Y)

func apply_modifiers(delta, turn_angle):
	# Rock effect stuns player after falling
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
	if is_network_master():
		if position.y > get_node("../FinishLine").position.y:
			if not finished:
				Network.notify_finish(player_id, race_time)
				finished = true
			return

		race_time += delta

		update_direction(delta)
		var turn_angle = update_accel()
		update_velocity(delta)
		apply_modifiers(delta, turn_angle)
		update_animation_frame()

		# Movimiento
		velocity = move_and_slide(velocity)

		# Voltear sprite
		if !facing_right and (rotation < PI/2) and (rotation > -PI/2):
			flip()

		# TODO: Hacer funcionar la actualización de posición con rset
		rpc_unreliable("_update_slave", player_id, position, rotation, sprite.rotation, sprite.scale)

remote func _update_slave(id, position, rotation, sprite_rotation, sprite_scale):
	Network.update_position(id, position, rotation, sprite_rotation, sprite_scale)

func on_slave_update(new_pos, new_rot, new_sprite_rot, new_sprite_scale):
	position = new_pos
	rotation = new_rot
	sprite.rotation = new_sprite_rot
	sprite.scale = new_sprite_scale

func _on_rock_collision() -> void:
	# First timer its the "falling" animation, second its the stuntime, third its innmunity
	stun_rotation_effect = true # Player can't turn
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
	var jump_time = JUMP_MAX_AIR_TIME*velocity.length()/current_MAX_SPEED
	set_collision_mask_bit(2, false) # Air, can't collide
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
	sprite.rotation = -PI/2

func object_stun() -> void:
	stun_effect = true # Player can't move
	set_collision_mask_bit(2, false) # Player can't collide objects
	yield(get_tree().create_timer(STUN_TIME), "timeout")
	stun_effect = false # Player can move
	stun_rotation_effect = false # Stop spinning
	sprite.rotation = -PI/2
	yield(get_tree().create_timer(STUN_INNMUNITY), "timeout")
	set_collision_mask_bit(2, true) # Player can collide objects

func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
