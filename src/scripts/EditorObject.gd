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

func _process(delta):
	global_position = get_global_mouse_position()
	can_place = !item_select.get_rect().has_point(get_viewport().get_mouse_position())
	
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
			camera.zoom -= Vector2(0.1, 0.1)
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			camera.zoom += Vector2(0.1, 0.1)
	
	if event is InputEventMouseMotion and is_panning:
		cam_container.global_position -= event.relative * camera.zoom
