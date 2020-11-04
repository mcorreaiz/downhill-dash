# Este script está cargado en "Autoload" dentro la configuración del proyecto

extends Node

enum {
	PLAY
	EDIT
}

var mode = PLAY

# Editor vars
var remove_trees = false
var add_trees = false

func _ready():
	pass # Replace with function body.
