extends Node2D


signal rock_collision


func _ready():
	pass


func _on_Area2D_body_entered(body):
	if (body.name != "TileMap"):
		emit_signal("rock_collision")