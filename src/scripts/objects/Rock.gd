extends "Entity.gd"

signal rock_collision

func _ready():
	pass


func _on_Rock_body_entered(body):
	if (body is KinematicBody2D):
		# Needs to trigger a sound as feedback
		$RockHitSound.play()
		emit_signal("rock_collision")
