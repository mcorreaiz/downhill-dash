# Base class for all obstacles
extends Area2D

var is_clicked

func _ready():
	connect("input_event", self, "_item_clicked")

func _item_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		is_clicked = event.is_action_pressed("mb_left")
		
func _process(delta):
	if Globals.mode == Globals.EDIT and is_clicked:
		global_position = get_global_mouse_position()
