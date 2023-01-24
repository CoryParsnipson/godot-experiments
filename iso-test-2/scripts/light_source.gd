extends Node2D

export (ShaderMaterial) onready var tilemap_mat;

func _ready():
	update_shader()


func _process(_delta):
	update_shader()


func update_shader():
	if (!tilemap_mat):
		return
	tilemap_mat.set_shader_param("origin", get_global_transform_with_canvas().origin);
