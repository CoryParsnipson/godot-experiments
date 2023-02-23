extends "res://scenes/_debug/debug.gd"

export (NodePath) onready var info = get_node(info)

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var global_mouse_pos = get_global_mouse_position()
	
	info.text = "scr: (%d, %d)\nwld: (%d, %d)" % [mouse_pos.x, mouse_pos.y, global_mouse_pos.x, global_mouse_pos.y]
	$"ui-layer/ui-root".rect_global_position = mouse_pos + offset
