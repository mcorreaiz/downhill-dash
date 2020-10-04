extends Node2D


signal ice_collision


func _ready():
	pass


func _on_Area2D_body_entered(body):
	emit_signal("ice_collision")
