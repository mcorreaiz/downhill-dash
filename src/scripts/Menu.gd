extends Control

onready var PlayButton = $VBoxContainer/PlayButton
onready var TrackList = $TrackModal/TrackList
onready var StartButton = $StartButton
onready var TrackModal = $TrackModal
onready var http = $HTTPRequest
onready var Coins = $Panel/GridContainer/Coin/CoinLabel

var track_owner = {
	"Tutorial": "admin",
}

func _ready():
	TrackList.add_item("Tutorial")
	TrackList.select(0)
	Coins.text = String(Firebase.user.coins)
	var path = "/users/%s/tracks?mask.fieldPaths=name" % Firebase.user.name
	Firebase.get_document(path, http)
	
	Network.connect('notify_lobby', self, '_on_player_connected')

func _on_PlayButton_pressed():
	if Network.test_create_server():
		$TrackModal.popup()
	else:
		Network.connect_to_server(Firebase.user.name)

func _on_StartButton_pressed():
	Network.start_game()

func _on_TrackModal_confirmed():
	var track_index = TrackList.get_selected_items()[0]
	var track_name = TrackList.get_item_text(track_index)
	Network.setup_server(Firebase.user.name, track_owner[track_name], track_name)

	PlayButton.text = "Jugadores en la sala: %s" % Firebase.user.name
	StartButton.visible = true
	
	Rewards.current_track_name = track_name
	Rewards.current_track_owner = track_owner[track_name]

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var tracks = parse_json(body.get_string_from_utf8())

	if tracks:
		for track in tracks.documents:
			var track_name = track.name.split("/")[-1]
			TrackList.add_item(track_name)
			track_owner[track_name] = Firebase.user.name


func _on_TrackList_nothing_selected():
	TrackList.select(0)

func _on_player_connected():

	var names = PoolStringArray(Network.get_player_names()).join(", ")
	PlayButton.text = "Jugadores en la sala: %s" % names
