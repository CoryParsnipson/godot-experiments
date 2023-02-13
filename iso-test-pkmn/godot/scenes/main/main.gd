extends Node2D


func _ready():
	$"pixel-upscale".scale = Singleton.pixel_upscale
