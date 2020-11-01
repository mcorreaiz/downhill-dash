extends Node2D

var can_place = true
onready var level = get_node("../Level")
onready var item_select = get_node("../ItemSelect")
var current_item

func _ready():
	Globals.mode = Globals.EDIT

func _process(delta):
	global_position = get_global_mouse_position()
	
	can_place = !item_select.get_rect().has_point(global_position)
	
	if Input.is_action_just_released("mb_left"):
		if current_item != null and can_place:
			var new_item = current_item
			level.add_child(new_item)
			new_item.global_position = get_global_mouse_position()
			
		current_item = null
		$Sprite.texture = null
