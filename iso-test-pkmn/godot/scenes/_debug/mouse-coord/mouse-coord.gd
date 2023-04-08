tool
extends "res://scenes/_debug/debug.gd"

export (NodePath) var info

func _process(_delta):
	if Engine.editor_hint:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var global_mouse_pos = get_global_mouse_position()
	
	var disp = get_node(info)
	disp.text = "scr: (%d, %d)\nwld: (%d, %d)" % [mouse_pos.x, mouse_pos.y, global_mouse_pos.x, global_mouse_pos.y]
	$"debug-layer/ui-root".rect_global_position = mouse_pos + offset
