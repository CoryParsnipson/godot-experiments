extends Node2D
class_name Door

enum DoorType { Door, Upstairs, Downstairs }

export (String, FILE) var destination_scene
export (String) var destination_spawn_id
export (DoorType) var type = DoorType.Door
export (lib_movement.Direction) var facing = lib_movement.Direction.SOUTH_EAST
export (bool) var destroy_old_scene = true


func on_trigger_entered(body):
	var mv = body.find_node("movement")
	if not mv:
		return
	
	mv.connect("move", self, "enter_door")


func on_trigger_exited(body):
	var mv = body.find_node("movement")
	if not mv:
		return
	
	mv.call_deferred("disconnect", "move", self, "enter_door")


func can_enter(_movement, entity) -> bool:
	# only want to trigger stairs cutscene if player moves into it
	if entity.direction != facing or destination_scene.empty():
		return false
	
	return true


## this function is for inheritors to customize door transition function of enter_door(). This
## function is called *before* the Door base class calls game.swap_scene().
func _pre_enter_door(level, _movement, entity):
	var player_dir = entity.direction
	var spawns = level.get_spawn_points()
	if destination_spawn_id in spawns:
		var spawn = spawns[destination_spawn_id]
		var dest_portal = spawn.get_node(spawn.portal)
		if dest_portal:
			player_dir = dest_portal.facing
			# TODO: need to flip this vector 180 degrees
	
	level.post_load_actions.append(
		SpawnCommand.new().set_data({
			"level" : level,
			"spawn-id" : destination_spawn_id,
			"spawn-props" : { "direction" : player_dir },
			"spawner-return-key" : "last-spawn-point",
			"return-key" : "target",
		})
	)
	level.post_load_actions.append(
		AttachCameraCommand.new().set_data({
			"level" : level,
			# "target" datum is set by SpawnCommmand return_key above
		})
	)


## this function is for inheritors to customize door transition function of enter_door(). This
## function is called *after* the Door base class calls game.swap_scene().
func _post_enter_door(_level, _movement, _entity):
	pass


func enter_door(movement, entity):
	if not can_enter(movement, entity):
		return
	
	var level = load(destination_scene).instance()
	
	# disable player input
	var prev_input_mode = game.set_input_mode(game.InputMode.CUTSCENE)
	movement.enable = false
	
	# wait until the end of the update cycle, so movement disable can take effect
	yield(get_tree(), "idle_frame")
	
	_pre_enter_door(level, movement, entity)
	game.swap_scene(level, destroy_old_scene)
	_post_enter_door(level, movement, entity)

	game.set_input_mode(prev_input_mode)
