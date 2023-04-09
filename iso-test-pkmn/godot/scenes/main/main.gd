extends Node2D

export (NodePath) onready var level_root = get_node(level_root)
export (NodePath) onready var screen_wipe = get_node(screen_wipe)
export (NodePath) onready var dialogue_manager = get_node(dialogue_manager)

export (String, FILE) var initial_scene

func _ready():
	# initialize items from config settings
	$"pixel-upscale".scale = game.pixel_upscale
	
	# locate services
	game.level_root = level_root
	game.screen_wipe = screen_wipe
	game.dialogue = dialogue_manager

	# load initial scene
	var initial_scene_inst = load(initial_scene).instance()
	if not initial_scene_inst is Level:
		print("[ERROR] main.ready: initial scene does not point to valid Level object. (%s)" % initial_scene_inst)
		return
	game.push_scene(initial_scene_inst)
