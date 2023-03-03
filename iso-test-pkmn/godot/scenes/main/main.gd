extends Node2D

export (NodePath) onready var dialogue_manager = get_node(dialogue_manager)

func _ready():
	$"pixel-upscale".scale = game.pixel_upscale

	# locate services
	game.dialogue_manager = dialogue_manager
