extends TextureRect

export(PackedScene) var this_scene
export(bool) var remove_trees = false
export(bool) var add_trees = false

onready var object_cursor = get_node("/root/Editor/EditorObject")
onready var cursor_sprite = object_cursor.get_node("Sprite")

func _ready():
	connect("gui_input", self, "_item_clicked")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	$Label.hide()

func _on_mouse_entered():
	$Label.show()
	
func _on_mouse_exited():
	$Label.hide()

func _item_clicked(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("mb_left"):
			object_cursor.current_item = this_scene
			cursor_sprite.texture = texture
			Globals.remove_trees = remove_trees
			Globals.add_trees = add_trees
