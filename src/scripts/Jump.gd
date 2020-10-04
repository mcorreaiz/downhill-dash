extends Node2D


signal jump_exit


func _ready():
	pass


func _on_Area2D_body_exited(body):
	if (body.name != "TileMap"):
		emit_signal("jump_exit")

