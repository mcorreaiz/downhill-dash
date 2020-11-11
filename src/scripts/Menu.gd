extends Control

onready var CreateButton = $VBoxContainer/CreateButton
onready var TrackList = $TrackModal/TrackList
onready var StartButton = $StartButton
onready var TrackModal = $TrackModal
onready var http = $HTTPRequest

var track_owner = {
	"Tutorial": "admin",
}

func _ready():
	TrackList.add_item("Tutorial")
	TrackList.select(0)
	get_node("Panel/GridContainer/Coin/CoinLabel").text = String(Firebase.user.coins)
	var path = "/users/%s/tracks?mask.fieldPaths=name" % Firebase.user.name
	Firebase.get_document(path, http)

func _on_CreateButton_pressed():
	$TrackModal.popup()

func _on_JoinButton_pressed():
	Network.connect_to_server(Firebase.user.name)

func _on_StartButton_pressed():
	Network.start_game()

func _on_TrackModal_confirmed():
	var track_index = TrackList.get_selected_items()[0]
	var track_name = TrackList.get_item_text(track_index)
	Network.create_server(Firebase.user.name, track_owner[track_name], track_name)

	CreateButton.disabled = true
	CreateButton.text = "Hay 1 jugador en tu juego"
	StartButton.visible = true

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var tracks = parse_json(body.get_string_from_utf8())

	if tracks:
		for track in tracks.documents:
			var track_name = track.name.split("/")[-1]
			TrackList.add_item(track_name)
			track_owner[track_name] = Firebase.user.name


func _on_TrackList_nothing_selected():
	TrackList.select(0)
