extends Node2D

export (NodePath) onready var level_root = get_node(level_root)
export (NodePath) onready var screen_wipe = get_node(screen_wipe)
export (NodePath) onready var dialogue_manager = get_node(dialogue_manager)


func _ready():
	# initialize items from config settings
	$"pixel-upscale".scale = game.pixel_upscale
	
	# locate services
	game.level_root = level_root
	game.screen_wipe = screen_wipe
	game.dialogue = dialogue_manager
