extends "res://scenes/_debug/debug.gd"

export (float) onready var marker_size = 4.0
export (Color) onready var position_color = Color.orange
export (Color) onready var destination_color = Color.purple
export (Color) onready var blocked_color = Color.darkred

var _tilemap = null

func _ready():
	_tilemap = lib_tilemap.get_nearest_tilemap(entity)
	
