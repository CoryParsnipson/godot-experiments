extends Node2D

export (NodePath) onready var entity = get_node(entity)
export (Vector2) var offset = Vector2(0, 0)
export (bool) var local_enable = true
export var smoothing_factor = 5


func is_enabled():
	return local_enable and Singleton.debug_enable


func hide():
	.hide()
	$"ui-layer/ui-root".hide()
	

func show():
	.show()
	$"ui-layer/ui-root".show()
	

func set_position(pos):
	$"ui-layer/ui-root".rect_position = pos


func lerp_to_position(pos, delta):
	$"ui-layer/ui-root".rect_position = lerp(
		$"ui-layer/ui-root".rect_position,
		pos,
		delta * smoothing_factor
	)


func _ready():
	set_position(entity.get_global_transform_with_canvas().origin)


func _physics_process(delta):
	if not is_enabled() and visible:
		hide()
		return
	elif is_enabled() and not visible:
		show()
		
	lerp_to_position(entity.get_global_transform_with_canvas().origin + offset, delta)
