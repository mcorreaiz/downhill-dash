extends Control


const FIREBASE_FUNCTIONS_ENDPOINT_URL = "https://us-central1-downhill-dash.cloudfunctions.net/app"
const REWARDS_TABLE = {
	5: ['20', '15', '10', '5', '-5', '-5'],
	25: ['65', '50', '20', '10', '-25', '-25'],
	180: ['360', '270', '90', '45', '-180', '-180'],
}


func _ready():
	pass # Replace with function body.

func http_request(url: String, signal_conection: String):
	var http := HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, signal_conection)
	
	var err = http.request(url)
	if err != OK:
		push_error("An error occurred in the HTTP request.")

func add_coins(player_name: String, bet: int, position: int) -> void:
	var url := FIREBASE_FUNCTIONS_ENDPOINT_URL
	var coins: String = REWARDS_TABLE[bet][position-1]
	url = url + '/addCoins/' + player_name + '/' + coins
	http_request(url, "_add_coins_request_completed")

func _add_coins_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print("add coins: ", response)

func add_achievement(player_name: String, achievement_name: String) -> void:
	var url := FIREBASE_FUNCTIONS_ENDPOINT_URL
	url = url + '/addAchievement/' + player_name + '/' + achievement_name
	http_request(url, "_add_achievement_request_completed")
	
func achievement_checker(achievements):
	var unlocked_achievements = []
	
	for new_achievement in unlocked_achievements:
		add_achievement(Globals.PLAYER_NAME, new_achievement)


func _add_achievement_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print("add achievement: ", response)

func check_daily(player_name: String) -> void:
	var url := FIREBASE_FUNCTIONS_ENDPOINT_URL
	url = url + '/checkDaily/' + player_name
	http_request(url, "_check_daily_request_completed")

func _check_daily_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print("Check daily: ", response)

func change_tier(player_name: String, new_tier: int) -> void:
	var url := FIREBASE_FUNCTIONS_ENDPOINT_URL
	url = url + '/checkDaily/' + player_name
	http_request(url, "_change_tier_request_completed")

func _change_tier_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print("Changed tier: ", response)

func change_track_time(player_name: String, track_owner: String, track_name: String, time: float) -> void:
	var url := FIREBASE_FUNCTIONS_ENDPOINT_URL
	url = url + '/changeTrackTime/' + player_name + '/' + track_owner + '/' + track_name + '/' + String(time)
	http_request(url, "_change_track_time_completed")

func _change_track_time_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print("Changed track time: ", response)

