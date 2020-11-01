extends Node2D

signal rock_collision
var is_clicked

func _ready():
	$Area2D.connect("input_event", self, "_item_clicked")

func _on_Area2D_body_entered(body):
	if (body is KinematicBody2D):
		# Needs to trigger a sound as feedback
		$RockHitSound.play()
		emit_signal("rock_collision")

func _item_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		is_clicked = Globals.mode == Globals.EDIT and event.is_action_pressed("mb_left")
		
func _process(delta):
	if is_clicked:
		global_position = get_global_mouse_position()
