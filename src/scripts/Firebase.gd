# https://github.com/GDQuest/godot-demos/blob/master/2019/05-21-firebase-firestore/end/static/Firebase.gd
extends Node

const API_KEY := Globals.FIREBASE_API_KEY
const PROJECT_ID := "downhill-dash"

const REGISTER_URL := "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=%s" % API_KEY
const LOGIN_URL := "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=%s" % API_KEY
const FIRESTORE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents" % PROJECT_ID
const FUNCTIONS_URL := "https://us-central1-downhill-dash.cloudfunctions.net/app"

var user = {}

func _get_request_headers() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Accept: application/json"
	])

func login(name: String, http: HTTPRequest):
	var url := FUNCTIONS_URL + "/login/" + name
	return http.request(url, ["Content-Length: 0"], false, HTTPClient.METHOD_POST)

func get_document(path: String, http: HTTPRequest):
	var url := FIRESTORE_URL + path.replace(" ", "%20")
	return http.request(url, _get_request_headers(), false, HTTPClient.METHOD_GET)

# Update or create a document
func update_document(path: String, fields: Dictionary, http: HTTPRequest):
	var document := { "fields": fields }
	var body := JSON.print(document)
	var url := FIRESTORE_URL + path.replace(" ", "%20")
	return http.request(url, _get_request_headers(), false, HTTPClient.METHOD_PATCH, body)

func delete_document(path: String, http: HTTPRequest):
	var url := FIRESTORE_URL + path.replace(" ", "%20")
	return http.request(url, _get_request_headers(), false, HTTPClient.METHOD_DELETE)
