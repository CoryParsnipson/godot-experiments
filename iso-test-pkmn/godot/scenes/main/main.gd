extends Node2D

export (NodePath) onready var level_root = get_node(level_root)
export (NodePath) onready var screen_wipe = get_node(screen_wipe)
export (NodePath) onready var dialogue_manager = get_node(dialogue_manager)


func _ready():
	$"pixel-upscale".scale = game.pixel_upscale

	# set level root
	game.level_root = level_root

	game.screen_wipe = screen_wipe

	# locate services
	game.dialogue = dialogue_manager

	# initialize first scene (TODO: should this go somewhere else?)
	var level = level_root.get_child(0)
	if level:
		var spawns = level.get_spawn_points()
		if  "new-game" in spawns:
			var player = spawns["new-game"].spawn()
			var camera = level.get_node("Camera2D")
			if player and camera:
				camera.get_parent().remove_child(camera)
				player.add_child(camera)
				player.direction = lib_movement.Direction.NORTH_EAST
