extends Node2D

export (bool) var show_visual = false
export (PackedScene) var entity_to_spawn
export (String) var spawn_instance_name = ""
export (NodePath) var destination_nodepath
export (NodePath) var spawn_position


func _ready():
	$"debug-layer/ui-root/visual".rect_position = \
		get_global_transform_with_canvas().origin - $"debug-layer/ui-root/visual".rect_size / 2
	
	spawn_position = get_node_or_null(spawn_position)
	
	if show_visual:
		$"debug-layer/ui-root/visual".show()
	else:
		$"debug-layer/ui-root/visual".hide()


func spawn(props = {}):
	var inst = entity_to_spawn.instance()
	inst.position = position if not spawn_position else spawn_position.global_position
	
	if not spawn_instance_name.empty():
		inst.name = spawn_instance_name
	
	for key in props:
		inst.set(key, props[key])
	
	var insertion_point = self if not destination_nodepath else get_node_or_null(destination_nodepath)
	if not insertion_point:
		print("[ERROR] spawner (%s).spawn: invalid destination_nodepath (%s)" % [name, destination_nodepath])
		return {}
	
	insertion_point.add_child(inst)
	return inst
