extends Camera2D

export (bool) onready var enable
export (NodePath) onready var player = get_node(player)

var game_size := Vector2(640, 360)
onready var window_scale := (OS.window_size / game_size).x
onready var actual_cam_pos := global_position


func _process(delta):
	if (not enable):
		return
	
	#var mouse_pos = Singleton.viewport.get_mouse_position() / window_scale - (game_size / 2) + player.global_position
	#var cam_pos = lerp(player.global_position, mouse_pos, 0.7)
	
	var cam_pos = lerp(global_position, player.global_position, 0.7)
	
	actual_cam_pos = lerp(actual_cam_pos, cam_pos, delta * 5)
	var subpixel_position = actual_cam_pos.round() - actual_cam_pos
	
	Singleton.viewport_container.material.set_shader_param("cam_offset", subpixel_position)
	global_position = actual_cam_pos.round()
