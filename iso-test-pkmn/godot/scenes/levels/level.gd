extends Node2D
class_name Level

var default_load_actions = MultiCommand.new("DefaultLoadActions")
var post_load_actions = MultiCommand.new("PostLoadActions")


func _ready():
	if post_load_actions.empty():
		_run_default_load_actions()
	
	_run_post_load_actions()


func get_spawn_points():
	if not is_inside_tree():
		var nodes_to_check = get_children()
		var spawns = {}
		
		while nodes_to_check.size() > 0:
			var front = nodes_to_check.front()
			if front.is_in_group("spawn_points"):
				spawns[front.name] = front
			
			nodes_to_check += front.get_children()
			nodes_to_check.pop_front()
		
		return spawns
	
	var spawns = get_tree().get_nodes_in_group("spawn_points")
	var spawns_in_scene = {}
	
	for spawn in spawns:
		if not has_node(spawn.get_path()):
			continue
		spawns_in_scene[spawn.name] = spawn
		
	return spawns_in_scene


## these actions will be run by default if nothing in post_load_actions is added
## This is for when you need to perform actions when loading a level and it is
## independent of whomever is loading it.
func _run_default_load_actions():
	if not default_load_actions is MultiCommand:
		print("[WARNING] level (%s).run_default_load_actions: expecting MultiCommand, received %s" % [name, default_load_actions])	
		return
	
	default_load_actions.execute()


## these actions should be run before the scene is interacted with, but after it's
## initialized and added to the scene tree. If post load actions is not empty,
## do not perform default load actions.
func _run_post_load_actions():
	if not post_load_actions is MultiCommand:
		print("[WARNING] level (%s).run_post_load_actions: expecting MultiCommand, received %s" % [name, post_load_actions])
		return
	
	post_load_actions.execute()
