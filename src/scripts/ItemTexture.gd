extends TextureRect

export(PackedScene) var this_scene

onready var object_cursor = get_node("/root/Editor/EditorObject")
onready var cursor_sprite = object_cursor.get_node("Sprite")

func _ready():
	connect("gui_input", self, "_item_clicked")

func _item_clicked(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("mb_left"):
			object_cursor.current_item = this_scene
			cursor_sprite.texture = texture