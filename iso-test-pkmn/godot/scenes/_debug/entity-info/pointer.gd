extends VBoxContainer

export (NodePath) onready var entity_info = get_node(entity_info)
export (int) var tip_length = 16

var _is_minimized = false setget on_resize


func on_resize(is_minimized):
	_is_minimized = is_minimized


func _ready():
	if entity_info:
		entity_info.connect("ready", self, "_on_entity_info_ready")
	

func _on_entity_info_ready():
	_is_minimized = entity_info._is_minimized


func _draw():
	if _is_minimized:
		return
	
	var entity_pos = entity_info.entity.get_global_transform_with_canvas().origin if entity_info.entity else Vector2(0, 0)
	var info_pos = get_canvas_transform() * rect_global_position
	
	# move the info pos to middle of the box
	info_pos.y += rect_size.y / 2 + entity_info.offset.y / 2

	entity_pos -= get_global_transform_with_canvas().origin
	info_pos -= get_global_transform_with_canvas().origin
	
	# NOTE: for some reason, at the start, entity_pos is incorrect. Clicking the minimize button
	# will call this method after a while and then the position will be correct.	
	#draw_circle(entity_pos, 6.0, Color.green)
	
	# calculate vert positions
	var tip = (entity_pos - info_pos).normalized() * tip_length
	
	var upper_corner = info_pos
	upper_corner.y += 10
	
	var lower_corner = info_pos
	lower_corner.y -= 10
	
	var verts = PoolVector2Array()
	verts.push_back(tip + info_pos)
	verts.push_back(upper_corner)
	verts.push_back(lower_corner)
	
	var colors = PoolColorArray()
	
	# TODO: get color from entity-info canvas item node
	colors.push_back(Color8(45, 31, 59))
	colors.push_back(Color8(45, 31, 59))
	colors.push_back(Color8(45, 31, 59))
	
	draw_polygon(verts, colors, PoolVector2Array(), null, null, true)
	update()
