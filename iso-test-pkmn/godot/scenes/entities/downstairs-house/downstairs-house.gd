extends Node2D

export (lib_movement.Direction) var facing = lib_movement.Direction.NORTH_WEST
export (String, FILE) var destination


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


func enter_stairs(movement, entity):
	var player_dir_on_pre_move = lib_movement.vector_to_direction(
		lib_isometric.cartesian_to_isometric(entity.movement_vector))

	# only want to trigger stairs cutscene if player moves into it	
	if player_dir_on_pre_move != facing:
		return
	
	# disable player input
	var prev_input_mode = game.input_mode
	game.input_mode = game.InputMode.CUTSCENE
	
	# cancel the movement initiated by trigger entrance
	movement.enable = false
	movement.cancel_movement()
	
	# manually set animation to walk cycle
	var anim = entity.find_node("animations")
	if anim:
		anim.play(lib_movement.get_animation_id(lib_movement.MoveState.WALK, player_dir_on_pre_move))
	else:
		print("[WARNING] upstairs-house.enter_stairs: triggered entity has no animations component")
	
	# disable collisions
	var col = entity.get_node_or_null("collider")
	if col:
		col.disabled = true

	# move sprite up stairs
	movement.enable = true
	entity.walk_speed = entity.walk_speed / 2
	entity.movement_state = lib_movement.MoveState.WALK
	movement.set_destination(movement._tilemap, Vector2(-1, 0))
	
	# fade to black
	game.screen_wipe.wipe(ScreenWipe.Type.FADE_TO_BLACK)
	yield(game.screen_wipe, "screen_wipe_done")

	# change scenes
	var level = load(destination)
	var scenes = game.swap_scene(level, true)
	var new_level = scenes[0]
	
	# TODO: everything below this line actually should belong to door in new scene??
	# spawn player character at opposite end of stairs
	var spawns = new_level.get_spawn_points()
	if "downstairs" in spawns:
		var player = spawns["downstairs"].spawn()

		# attach camera to player
		var camera = new_level.get_node_or_null("Camera2D")
		if camera:
			camera.get_parent().remove_child(camera)
			player.add_child(camera)

	# fade to normal
	game.screen_wipe.wipe(ScreenWipe.Type.FADE_TO_NORMAL)
	#yield(game.screen_wipe, "screen_wipe_done")

	# re-enable player input
	game.input_mode = prev_input_mode

