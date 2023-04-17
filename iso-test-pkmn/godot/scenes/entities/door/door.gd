extends "res://scenes/gizmos/spawner/spawner.gd"
class_name Door

enum DoorType { Door, Upstairs, Downstairs }
enum DoorAction { Enter, Exit }

export (String, FILE) var destination_scene
export (String) var destination_spawn_id
export (DoorType) var type = DoorType.Door
export (lib_movement.Direction) var facing = lib_movement.Direction.NORTH_WEST
export (bool) var destroy_old_scene = true


## this function should be used by inheritors to construct the proper animation string to use
## when playing character animation entering or exiting this door. This string is used by both
## the character animations and the door paths.
##
## door_type -> provide a Door.DoorType
## door_action -> provide a Door.DoorAction
## direction -> direction that the door is facing
static func animation_id(door_type, door_action, direction):
	return "%s-%s-%s" % [
		DoorType.keys()[door_type].to_lower(),
		DoorAction.keys()[door_action].to_lower(),
		lib_movement.direction_suffix_str(direction)
	]


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
	if entity.direction != lib_movement.invert_direction(facing) or destination_scene.empty():
		return false
	
	return true


## this function is for inheritors to customize door transition function of enter_door(). This
## function is called *before* the Door base class calls game.swap_scene().
func _pre_enter_door(level, _movement, entity):
	var player_dir = entity.direction
	var spawns = level.get_spawn_points()
	if destination_spawn_id in spawns:
		var spawn = spawns[destination_spawn_id]
		
		# ideally this should be `if spawn is Door:` but we can't use class name in its own file
		if spawn.get("facing") != null:
			player_dir = lib_movement.invert_direction(spawn.facing)
	
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
	movement.cancel_movement()
	movement.enable = false
	
	# wait until the end of the update cycle, so movement disable can take effect
	yield(get_tree(), "idle_frame")
	
	var ret = _pre_enter_door(level, movement, entity)
	if ret is GDScriptFunctionState:
		yield(ret, "completed")
	
	# re-enable player input
	level.post_load_actions.append(
		InputModeCommand.new().set_data({
			"input-mode" : prev_input_mode,
		})
	)
	
	game.swap_scene(level, destroy_old_scene)
	_post_enter_door(level, movement, entity)
