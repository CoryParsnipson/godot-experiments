extends Node2D

enum StairsType { Upstairs, Downstairs }

export (lib_movement.Direction) var facing = lib_movement.Direction.NORTH_WEST
export (String, FILE) var destination
export (String) var spawn_point

export (StairsType) var portal_type = StairsType.Downstairs


func on_trigger_entered(body):
	var mv = body.find_node("movement")
	if not mv:
		return
	
	mv.connect("move", self, "enter_stairs")


func on_trigger_exited(body):
	var mv = body.find_node("movement")
	if not mv:
		return
	
	mv.call_deferred("disconnect", "move", self, "enter_stairs")


func play_animation(entity, movement, portal_type_string, action_string):
	var animations = entity.find_node("animations")
	if not animations:
		return
	
	# create path string
	var path_selector = "%s-%s-%s" % \
		[portal_type_string, action_string, lib_movement.direction_suffix_str(movement.get_direction())]
	var path_follower_path = "paths/%s/path-follow" % path_selector
	var remote_transform_path = "%s/remote-transform" % path_follower_path
	
	animations.set_path_members(
		get_node(remote_transform_path).get_path(),
		get_node(path_follower_path).get_path(),
		entity.get_path()
	)
	animations.play(path_selector)


func enter_stairs(movement, entity):
	var player_dir_on_move = lib_movement.vector_to_direction(
		lib_isometric.cartesian_to_isometric(entity.movement_vector))

	# only want to trigger stairs cutscene if player moves into it	
	if player_dir_on_move != facing or destination.empty():
		return
	
	# disable player input
	var prev_input_mode = game.set_input_mode(game.InputMode.GAMEPLAY)
	movement.enable = false
	
	play_animation(entity, movement, str(StairsType.keys()[portal_type]).to_lower(), "enter")
	
	# fade to black
	game.screen_wipe.wipe(ScreenWipe.Type.FADE_TO_BLACK)
	yield(game.screen_wipe, "screen_wipe_done")

	# setup scene change
	var level = load(destination).instance()
	level.post_load_actions.append(
		SpawnCommand.new().set_data({
			"level" : level,
			"spawn-id" : spawn_point,
			"spawn-props" : { "direction" : player_dir_on_move },
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
	level.post_load_actions.append(
		PlayPortalAnimationCommand.new("UpstairsExitNWAnimation").set_fire_and_forget(true).set_data({
			"level" : level,
			# "last-spawn-point" datum is set by SpawnCommand "spawner-return-key" above
			# "target" datum is set by SpawnCommmand return_key above
			"facing" : movement.get_direction(),
		})
	)
	level.post_load_actions.append(
		ScreenWipeCommand.new().set_data({
			"screen-wipe" : game.screen_wipe,
			"type" : ScreenWipe.Type.FADE_TO_NORMAL,
		})
	)
	level.post_load_actions.append(
		InputModeCommand.new().set_data({
			"input-mode" : prev_input_mode,
		})
	)
	
	# change scene
	game.swap_scene(level, true)
