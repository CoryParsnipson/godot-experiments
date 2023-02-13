extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Singleton.viewport_container = $"smooth-camera-viewport-container"
	Singleton.viewport = $"smooth-camera-viewport-container/smooth-camera-viewport"
	
	# set game config vars
	$"smooth-camera-viewport-container/smooth-camera-viewport/pixel-upscale".scale = Singleton.pixel_upscale
