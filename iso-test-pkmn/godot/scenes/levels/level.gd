extends Node2D
class_name Level


func get_spawn_points():
	var spawns = get_tree().get_nodes_in_group("spawn_points")
	var spawns_in_scene = {}
	
	for spawn in spawns:
		if not has_node(spawn.get_path()):
			continue
		spawns_in_scene[spawn.name] = spawn
		
	return spawns_in_scene
