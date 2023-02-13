extends Node2D

export (NodePath) onready var entity = get_node(entity)
export (Vector2) var offset = Vector2(0, 0)
export (bool) var local_enable = true
export var smoothing_factor = 5

func _ready():
	$"ui-layer/ui-root".rect_position = entity.get_global_transform_with_canvas().origin

func _physics_process(delta):
	var pos = $"ui-layer/ui-root".rect_position
	var dest = entity.get_global_transform_with_canvas().origin + offset
	
	$"ui-layer/ui-root".rect_position = lerp(pos, dest, delta * smoothing_factor)
