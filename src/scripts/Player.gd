extends KinematicBody2D

onready var sprite: Sprite = $Sprite

slave var slave_position: Vector2 = Vector2()
slave var slave_movement: Vector2 = Vector2()

var facing_right: bool = true

var accel = Vector2()
var velocity = Vector2()

export (int) var speed = 10
export (int) var inertia = 30

const MAX_SPEED: int = 1000
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
	var mouse_pos = get_global_mouse_position()
	
	look_at(Vector2(mouse_pos.x, max(global_position.y, mouse_pos.y)))
	
	#La inercia se define en base al ángulo
	"""
	if rotation > 0:
		inertia = 30 * abs(sin(rotation))
	else:
		inertia = 0
 	"""
func update_accel():
	var ski_accel = Vector2(30, 0).rotated(rotation)
	var hill_accel = Vector2(0, abs(sin(rotation)) * 20)
	
	accel = ski_accel + hill_accel
	
func update_velocity():
		velocity += accel
		
		# Roce
		velocity *= 0.9
		
		#Velocidad máxima
		if velocity.y > MAX_SPEED:
			velocity.y = MAX_SPEED
			
func apply_modifiers():
	if rock_effect:
		velocity /= 1.5
		
func _physics_process(delta) -> void:
	Globals.race_time += delta
		
	if is_network_master():
		update_rotation()
		update_accel()
		update_velocity()
		apply_modifiers()

		#Movimiento
		velocity = move_and_slide(velocity)
		
		
		#Voltear sprite
		if !facing_right  and (rotation < PI/2) and (rotation > -PI/2):
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
