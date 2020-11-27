extends Node2D

var can_place = true
var is_panning = false
var current_item = null

var do_save = false

const TREE_PATH = "res://scenes/objects/Tree.tscn"

onready var level = get_node("../Level")

onready var bg = level.get_node("Background")
onready var sl = level.get_node("StartLine")

onready var cam_container = get_node("../CamContainer")
onready var camera = cam_container.get_node("Camera2D")

onready var item_select = get_node("../ItemSelect/PanelContainer")
onready var popup : ConfirmationDialog = get_node("../ItemSelect/SaveDialog")

func _ready():
	Globals.mode = Globals.EDIT
	camera.current = true
	spawn_trees()

func _process(delta):
	global_position = get_global_mouse_position()
	can_place = !item_select.get_rect().has_point(get_viewport().get_mouse_position())

	if Globals.remove_trees or Globals.add_trees:
		pass
	else:
		if (!Globals.filesystem_shown):
			if Input.is_action_just_released("mb_left"):
				if current_item != null and can_place:
					var new_item = current_item.instance()
					if new_item is RaceLine:
						# There can only be one
						var finish_line = level.get_node("FinishLine")
						if finish_line == null:
							new_item.name = "FinishLine"
						else:
							new_item = finish_line
					level.add_child(new_item)
					new_item.owner = level
					new_item.global_position = global_position

				current_item = null
				$Sprite.texture = null

func _unhandled_input(event):
	if (!Globals.filesystem_shown):
		is_panning = Input.is_action_pressed("mb_right")

	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
			camera.zoom /= 1.1 if camera.zoom.length() > 1 else 1
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			camera.zoom *= 1.1 if camera.zoom.length() < 5 else 1
	
	if event is InputEventMouseMotion and is_panning:
		var original = cam_container.global_position
		cam_container.global_position = Vector2(
			clamp(cam_container.global_position.x, -1000, 1000),
			clamp(cam_container.global_position.y, 0, 4000)
		)
		cam_container.global_position -= event.relative * camera.zoom

func spawn_trees():
	var tree = preload(TREE_PATH)
	var bg = level.get_node("Background")
	var size = bg.rect_size
	var pos = bg.rect_position
	for i in range(pos.x, pos.x + size.x, 100):
		for j in range(pos.y, pos.y + size.y, 100):
			if randf() > 0.3 and not_close_to_start_line(Vector2(i + 200, j - 200)):
				var new_tree = tree.instance()
				level.add_child(new_tree)
				new_tree.owner = level
				new_tree.global_position = Vector2(i + (randi() % 50 - 25), j + (randi() % 50 - 25))

func not_close_to_start_line(p):
	var sl = level.get_node("StartLine")
	var scaled = Rect2(sl.position, sl.get_node("Sprite").get_region_rect().size * sl.scale)
	var p_rect = Rect2(p, Vector2(200, 400))
	return ! scaled.intersects(p_rect)

func save_level(track_name):
	# Create file
	var to_save : PackedScene = PackedScene.new()
	# Make the level owner of child nodes so they get saved
	bg.owner = level
	sl.owner = level
	
	# Delete removed trees
	for node in level.get_children():
		var sprite = node.get_node("CollisionShape2D")
		if node.get_filename() == TREE_PATH and !sprite.visible:
			level.remove_child(node)
			node.free()
	
	to_save.pack(level)
	ResourceSaver.save(track_name + ".tscn", to_save)
	
	# Read file
	var file: File = File.new()
	file.open(track_name + ".tscn", File.READ)
	var fileAsString: String = file.get_as_text()
	file.close()
	
	# Upload file
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_save_completed")
	var track_format = "/users/%s/tracks/%s"
	var track_path = track_format % [Firebase.user.name, track_name]
	var body = {
		"file": {
		  "stringValue": fileAsString
		}
	}
	var error = Firebase.update_document(track_path, body, http)

func _on_save_completed(result, response_code, headers, body):
	_on_BackButton_pressed()

func load_level():
	var toLoad : PackedScene = PackedScene.new()
	toLoad = ResourceLoader.load(popup.current_path)
	var this_level = toLoad.instance()
	get_parent().remove_child(level)
	level.queue_free()
	get_parent().add_child(this_level)
	sl = get_parent().get_node("Level/StartLine")
	bg = get_parent().get_node("Level/Background")
	level = this_level

func _on_SaveDialog_confirmed():
	var track_name = popup.get_node("TrackNameEdit").text
	save_level(track_name)

func _on_FileDialog_hide():
	Globals.filesystem_shown = false
	do_save = false
	pass # Replace with function body.

func _on_BackButton_pressed():
	get_tree().change_scene("res://scenes/Base.tscn")
	queue_free()

func _on_SaveButton_pressed():
	popup.window_title = "Guardar pista"
	popup.popup_centered()

func _on_LoadButton_pressed():
	popup.window_title = "Cargar pista"
	Globals.filesystem_shown = true
	do_save = true
	popup.show()
