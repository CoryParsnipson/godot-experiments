extends Level


func _init():
	default_load_actions.append(
		SpawnCommand.new("SpawnAtNewGame").set_data({
			"level" : self,
			"spawn-id" : "initial-spawn",
			"spawn-props" : { "direction" : lib_movement.Direction.NORTH_EAST },
			"return-key" : "target",
		})
	)
	default_load_actions.append(
		AttachCameraCommand.new().set_data({
			"level" : self,
			# "target" datum is set by SpawnCommmand return_key above
		})
	)
