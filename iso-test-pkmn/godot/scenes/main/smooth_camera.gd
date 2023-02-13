extends Camera2D

export (bool) onready var enable
export (NodePath) onready var player = get_node(player)

onready var actual_cam_pos := global_position

func _process(delta):
	if (not enable):
		return
		
	var cam_pos = lerp(global_position, player.global_position, 0.7)
	
	actual_cam_pos = lerp(actual_cam_pos, cam_pos, delta * 5)
	var subpixel_position = actual_cam_pos.round() - actual_cam_pos
	
	Singleton.viewport_container.material.set_shader_param("cam_offset", subpixel_position)
	global_position = actual_cam_pos.round()
