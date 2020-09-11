extends KinematicBody2D

onready var sprite: Sprite = $Sprite

slave var slave_position = Vector2()
slave var slave_movement = Vector2()

var y_vel: int = 0
var timer = 0

var facing_right: bool = true
var rock_timer: int = OS.get_system_time_secs()

var accel = Vector2()
var velocity = Vector2()

export (int) var speed = 10
export (int) var inertia = 30


const MAX_SPEED: int = 1000
const ROCK = 3
const ROCK_DURATION = 2


func get_input():
	var mouse_pos = get_global_mouse_position()
	
	look_at(Vector2(mouse_pos.x, max(global_position.y, mouse_pos.y)))

	var ski_accel = Vector2(30, 0).rotated(rotation)
	var hill_accel = Vector2(0, abs(sin(rotation)) * 20)
	
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
	timer = OS.get_system_time_secs()
	
	
func _physics_process(delta) -> void:
	var current_time = OS.get_system_time_secs()
	
	if current_time < rock_timer:
		velocity.y /= 2
	else:
		$CollisionShape2D.disabled = false
		
		
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
		var tm = get_node("../Game/TileMap")
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var tile_pos = tm.world_to_map(collision.position)
			var tile = tm.get_cellv(tile_pos)
			print("I collided with ", tile)
			# get_tree().reload_current_scene()
			if tile == ROCK:
				$CollisionShape2D.disabled = true
				rock_timer = OS.get_system_time_secs() + ROCK_DURATION
			
			else:
				velocity /= 2
	
	else:
		pass
		# Ver como manejar el movimiento de los 'slaves'
		
	
	if position.y > 3500:
		Network.race_time = OS.get_system_time_secs() - timer
		Network.close()
		emit_signal('server_disconnected')		
		get_tree().change_scene('res://scenes/EndRace.tscn')
		queue_free()

	if get_tree().is_network_server():
		Network.update_position(int(name), position)	
	


func flip() -> void:
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h
