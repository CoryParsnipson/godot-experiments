extends Door


func _pre_enter_door(level, _movement, entity):
	var ret = MultiCommand.new().append(
		# fade to black
		ScreenWipeCommand.new().set_fire_and_forget(true).set_data({
			"screen-wipe" : game.screen_wipe,
			"type" : ScreenWipe.Type.FADE_TO_BLACK,
			"pre-wipe-delay" : 0.2,
		})
	).append(
		# play entrance animation
		PlayPortalAnimationCommand.new().set_data({
			"door" : self.get_path(),
			"door-action" : DoorAction.Enter,
			"target" : entity.get_path(),
		})
	).execute()
	if ret is GDScriptFunctionState:
		yield(ret, "completed")
	
	# prepare post load actions of next scene
	level.post_load_actions.append(
		SpawnCommand.new().set_data({
			"level" : level,
			"spawn-id" : destination_spawn_id,
			"spawn-props" : { "direction" : entity.direction },
			"spawner-return-key" : "door",
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
		ScreenWipeCommand.new().set_fire_and_forget(true).set_data({
			"screen-wipe" : game.screen_wipe,
			"type" : ScreenWipe.Type.FADE_TO_NORMAL,
			"pre-wipe-delay" : 0.1,
		})
	)
	level.post_load_actions.append(
		PlayPortalAnimationCommand.new("UpstairsExitNWAnimation").set_data({
			# "door" datum is set by SpawnCommand "spawner-return-key" above
			"door-action" : DoorAction.Exit,
			# "target" datum is set by SpawnCommmand return_key above
		})
	)
