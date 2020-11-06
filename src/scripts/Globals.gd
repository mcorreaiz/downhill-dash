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

var filesystem_shown= false
