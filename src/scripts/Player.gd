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
const MIN_SPEED_Y: int = 30
const MIN_DIR_Y: float = 0.4

const ROCK: int = 3
const ROCK_DURATION: int = 2

var rock_effect: bool = false
var ice_effect: bool = false
var jump_effect: bool = false

signal rock_collision # Debe pertenecer a Rock.gd

func _ready():
	connect("rock_collision", self, "_on_rock_collision")
	
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
	var turn_angle = clamp(abs(direction.angle_to(velocity)), 0, PI/2)
	
	var accel_mult = 1 + 2 * (MAX_SPEED - velocity.length()) / MAX_SPEED
	var frict_mult = 2 - (MAX_SPEED - velocity.length()) / MAX_SPEED
	
	var dir_accel = Vector2(cos(angle_y_axis), 0).rotated(direction.angle()) * accel_mult
	var dir_friction = Vector2(sin(turn_angle), 0).rotated(velocity.angle()) * frict_mult
	
	accel = (dir_accel - dir_friction) * sin(hill_slope) * gravity
	
func update_velocity(delta):
	velocity += accel * delta
	
	#Velocidad máxima
	velocity = velocity.clamped(MAX_SPEED)
	velocity.y = max(velocity.y, MIN_SPEED_Y)
	
func apply_modifiers():
	if rock_effect:
		pass
		
func _physics_process(delta) -> void:
	Globals.race_time += delta
		
	if is_network_master():
		update_rotation()
		update_accel()
		update_velocity(delta)
		apply_modifiers()

		#Movimiento
		velocity = move_and_slide(velocity)
		
		#Voltear sprite
		if !facing_right and (rotation < PI/2) and (rotation > -PI/2):
			flip()
		
		#Chequeo de colisión
		var tm = get_node("../Game/TileMap")
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var tile_pos = tm.world_to_map(collision.position)
			var tile = tm.get_cellv(tile_pos)
			# get_tree().reload_current_scene()
			if tile == ROCK and !rock_effect:
				# Esto debiera vivir en Rock.gd
				emit_signal("rock_collision")
	
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
	rock_effect = true
	$CollisionShape2D.set_deferred('disabled', true)
	yield(get_tree().create_timer(ROCK_DURATION), "timeout")
	$CollisionShape2D.set_deferred('disabled', false)
	rock_effect = false
	

func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
