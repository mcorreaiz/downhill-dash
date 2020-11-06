# Este script está cargado en "Autoload" dentro la configuración del proyecto

extends Node

const FIREBASE_API_KEY := ""
enum {
	PLAY
	EDIT
}

var mode = PLAY

# Editor vars
var remove_trees = false
var add_trees = false

const PLAYER_NAME = "juanito"
var track_owner = "juanito"
var track_name = "primera-pista"
var position = 3
var race_bet = 5
