tool
extends Node2D

export (NodePath) var entity
export (Vector2) var offset = Vector2(0, 0)
export (bool) var local_enable = false
export var smoothing_factor = 5


func is_enabled():
	return local_enable and game.debug_enable


func hide():
	.hide()
	$"debug-layer/ui-root".hide()
	

func show():
	.show()
	$"debug-layer/ui-root".show()
	

func set_position(pos):
	$"debug-layer/ui-root".rect_position = pos


func lerp_to_position(pos, delta):
	$"debug-layer/ui-root".rect_position = lerp(
		$"debug-layer/ui-root".rect_position,
		pos,
		delta * smoothing_factor
	)


func _on_visibility_changed():
	# this runs in the editor
	# need to toggle the visibility on everything in the debug layer when user clicks the eyeball icon
	if is_visible_in_tree():
		$"debug-layer/ui-root".show()
	else:
		$"debug-layer/ui-root".hide()


func _ready():
	_on_visibility_changed()
	if Engine.editor_hint:
		return
		
	entity = get_node(entity)
	set_position(entity.get_global_transform_with_canvas().origin)


func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	if not is_enabled() and visible:
		hide()
		return
	elif is_enabled() and not visible:
		show()
		
	lerp_to_position(entity.get_global_transform_with_canvas().origin + offset, delta)
