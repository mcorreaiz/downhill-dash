extends Node2D


signal ice_enter
signal ice_exit


func _ready():
	$Area2D/CollisionPolygon2D.polygon = $Area2D/Path2D.curve.tessellate()
	$Area2D/Polygon2D.polygon = $Area2D/Path2D.curve.tessellate()


func _on_Area2D_body_entered(body):
	if (body is KinematicBody2D):
		emit_signal("ice_enter")


func _on_Area2D_body_exited(body):
	if (body is KinematicBody2D):
		emit_signal("ice_exit")
