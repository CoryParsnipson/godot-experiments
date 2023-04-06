extends Level


func _init():
	default_load_actions.append(
		SpawnCommand.new("SpawnAtNewGame").set_data({
			"level" : self,
			"spawn_id" : "initial-spawn",
			"spawn_props" : { "direction" : lib_movement.Direction.NORTH_EAST },
			"return_key" : "target",
		})
	)
	default_load_actions.append(
		AttachCameraCommand.new().set_data({
			"level" : self,
			# "target" datum is set by SpawnCommmand return_key above
		})
	)
