extends Node2D

var can_place = true
var is_panning = false
var current_item = null

onready var level = get_node("../Level")
onready var cam_container = get_node("../CamContainer")
onready var item_select = get_node("../ItemSelect/PanelContainer")
onready var camera = cam_container.get_node("Camera2D")

func _ready():
	Globals.mode = Globals.EDIT
	camera.current = true
	spawn_trees()

func _process(delta):
	global_position = get_global_mouse_position()
	can_place = !item_select.get_rect().has_point(get_viewport().get_mouse_position())
	
	if Globals.remove_trees or Globals.add_trees:
		pass
	else:
		if Input.is_action_just_released("mb_left"):
			if current_item != null and can_place:
				var new_item = current_item.instance()
				level.add_child(new_item)
				new_item.global_position = global_position
				
			current_item = null
			$Sprite.texture = null
		
func _unhandled_input(event):
	is_panning = Input.is_action_pressed("mb_right")
	
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
			camera.zoom /= 1.1 if camera.zoom.length() > 1 else 1
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			camera.zoom *= 1.1 if camera.zoom.length() < 5 else 1
	
	if event is InputEventMouseMotion and is_panning:
		var original = cam_container.global_position
		cam_container.global_position = Vector2(
			clamp(cam_container.global_position.x, -1000, 1000),
			clamp(cam_container.global_position.y, 0, 4000)
		)
		cam_container.global_position -= event.relative * camera.zoom

func spawn_trees():
	var tree = preload("res://scenes/objects/Tree.tscn")
	var bg = level.get_node("Background")
	var size = bg.rect_size
	var pos = bg.rect_position
	for i in range(pos.x, pos.x + size.x, 100):
		for j in range(pos.y, pos.y + size.y, 100):
			if randf() > 0.3 and not_close_to_start_line(Vector2(i + 100, j - 200)):
				var new_tree = tree.instance()
				level.add_child(new_tree)
				new_tree.global_position = Vector2(i + (randi() % 50 - 25), j + (randi() % 50 - 25))

func not_close_to_start_line(p):
	var sl = level.get_node("StartLine")
	var scaled = Rect2(sl.position, sl.get_region_rect().size * sl.scale)
	var p_rect = Rect2(p, Vector2(200, 400))
	return ! scaled.intersects(p_rect)
