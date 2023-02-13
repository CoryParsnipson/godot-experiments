extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$"pixel-upscale".scale = Singleton.pixel_upscale
