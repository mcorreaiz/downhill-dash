extends "objects/Entity.gd"
class_name RaceLine

export(bool) var is_start = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_exited", self, "_player_finished")
	pass # Replace with function body.

func _player_finished(p):
	pass
	
func _item_clicked(viewport, event, shape_idx):
	if is_start:
		# Ignore, can't be dragged.
		return
	else:
		._item_clicked(viewport, event, shape_idx)


