# Este script está cargado en "Autoload" dentro la configuración del proyecto

extends Node

const FIREBASE_API_KEY := ""
enum {
	PLAY
	EDIT
}

var mode = PLAY

var remove_trees = false

func _ready():
	pass # Replace with function body.
