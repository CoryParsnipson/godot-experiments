extends Node2D

export (bool) var show_visual = false
export (String) var instance_name = ""

export (NodePath) var parent
export (PackedScene) var entity_to_spawn
export (NodePath) var portal


func _ready():
	$"debug-layer/ui-root/visual".rect_position = \
		get_global_transform_with_canvas().origin - $"debug-layer/ui-root/visual".rect_size / 2
	
	if show_visual:
		$"debug-layer/ui-root/visual".show()
	else:
		$"debug-layer/ui-root/visual".hide()


func spawn(props = {}):
	var inst = entity_to_spawn.instance()
	inst.position = position
	
	if not instance_name.empty():
		inst.name = instance_name
		
	var insertion_point = self if not parent else parent
	var place_to_insert = get_node(insertion_point)
	
	for key in props:
		inst.set(key, props[key])
	
	place_to_insert.add_child(inst)
	
	return inst
