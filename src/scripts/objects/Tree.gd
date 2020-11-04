extends Area2D

func _ready():
	connect("mouse_entered", self, "_remove")

func _remove():
	if Globals.remove_trees and Input.is_action_pressed("mb_left"):
		visible = false
