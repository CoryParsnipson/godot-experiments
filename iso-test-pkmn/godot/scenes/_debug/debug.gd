extends Node2D

export (NodePath) onready var entity = get_node(entity)
export (Vector2) var offset = Vector2(0, 0)
export (bool) var local_enable = true
export var smoothing_factor = 5


func is_enabled():
	return local_enable && Singleton.debug_enable


func hide():
	.hide()
	$"ui-layer/ui-root".hide()
	

func _ready():
	$"ui-layer/ui-root".rect_position = entity.get_global_transform_with_canvas().origin


func _physics_process(delta):
	if !is_enabled():
		hide()
		return
	
	var pos = $"ui-layer/ui-root".rect_position
	var dest = entity.get_global_transform_with_canvas().origin + offset
	
	$"ui-layer/ui-root".rect_position = lerp(pos, dest, delta * smoothing_factor)
