extends StaticBody2D

func _ready():
	$Area2D.connect("area_entered", self, "_add_remove")

func _add_remove(_a):
	if Input.is_action_pressed("mb_left"):
		$CollisionShape2D.visible = ($CollisionShape2D.visible or Globals.add_trees) and ! Globals.remove_trees
