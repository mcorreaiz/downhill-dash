extends Node2D


signal jump_exit


func _ready():
	pass


func _on_Area2D_body_exited(body):
	if (body is KinematicBody2D):
		# Needs to trigger a sound as feedback
		$JumpSound.play()
		emit_signal("jump_exit")

