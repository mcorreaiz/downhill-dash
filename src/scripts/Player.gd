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

const MAX_SPEED: int = 300
const MIN_SPEED_Y: int = 30
const MIN_DIR_Y: float = 0.4

const ROCK_FALLING: float = 0.5
const ROCK_STUN: float = 1.5
const ROCK_INNMUNITY: float = 1.0

var rock_effect: bool = false
var ice_effect: bool = false
var jump_effect: bool = false


func _ready():
	pass

func init(name, position, is_slave):
	$NameLabel.text = name
	global_position = position

func update_rotation():
	# TODO: refactorear usando angulos
	direction = (get_global_mouse_position() - global_position).normalized()
	direction.y = max(direction.y, MIN_DIR_Y)
	
	rotation = direction.angle()
	
func update_accel():
	var angle_y_axis = rotation - (PI / 2)
	var difference = clamp(abs(direction.angle_to(velocity)), 0, PI/2)
	
	var dir_accel = Vector2(cos(angle_y_axis), 0).rotated(direction.angle())
	var dir_friction = Vector2(sin(difference), 0).rotated(velocity.angle())
	
	accel = (dir_accel - dir_friction) * sin(hill_slope) * gravity
	
func update_velocity(delta):
	velocity += accel * delta
		
	#Velocidad máxima
	velocity.y = clamp(velocity.y, MIN_SPEED_Y, MAX_SPEED)

func apply_modifiers(delta):
	#Rock effect stuns player after falling
	if rock_effect:
		velocity = Vector2(0, 0)

func _physics_process(delta) -> void:
	Globals.race_time += delta
		
	if is_network_master():
		update_rotation()
		update_accel()
		update_velocity(delta)
		apply_modifiers(delta)

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
	
func _on_rock_collision():
	print("ROCK HIOT")
	# Needs to trigger an animation and a sound as feedback
	# First timer its the "falling" animation, second its the stuntime
	yield(get_tree().create_timer(ROCK_FALLING), "timeout")
	rock_effect = true #Player cant move
	set_collision_mask_bit(2, false)
	yield(get_tree().create_timer(ROCK_STUN), "timeout")
	rock_effect = false #Player starts to move
	yield(get_tree().create_timer(ROCK_INNMUNITY), "timeout")
	set_collision_mask_bit(2, true) #Player can hit a rock again
	
func _on_ice_collision():
	# Needs to trigger an animation and a sound as feedback
	print("Ice skiiiing")
	
func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
