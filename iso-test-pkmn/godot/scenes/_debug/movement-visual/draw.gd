extends CanvasItem

export (NodePath) onready var _dbg = get_node(_dbg)

var _offset  # offset from center of entity to the middle of the tile it's on
var _tile_half_size


func upscale(vec):
	var scaled_vec = vec
	scaled_vec.x *= game.pixel_upscale.x
	scaled_vec.y *= game.pixel_upscale.y
	return scaled_vec


func is_blocked(pos):
	var dest = lib_tilemap.map_to_world(_dbg._tilemap, pos)
	var dist = dest - _dbg.entity.global_position
	return _dbg.entity.test_move(_dbg.entity.global_transform, dist)


func draw_tile_marker(pos, marker_size, color):
	draw_circle(pos, marker_size, color)
	
	var arr = PoolVector2Array()
	arr.push_back(pos - Vector2(_tile_half_size.x, 0))
	arr.push_back(pos - Vector2(0, _tile_half_size.y))
	arr.push_back(pos + Vector2(_tile_half_size.x, 0))
	arr.push_back(pos + Vector2(0, _tile_half_size.y))
	arr.push_back(pos - Vector2(_tile_half_size.x, 0))
	
	draw_polyline(arr, color, 4.0, true)


func _ready():
	yield(get_node(_dbg.entity), "ready")
	
	var collider = _dbg.entity.get_node_or_null("collider")
	_offset = upscale(collider.position if collider else Vector2(0, 0))
	
	_tile_half_size = upscale(_dbg._tilemap.cell_size / 2)


func _draw():
	if not _dbg or not _dbg.is_enabled():
		return
	
	# to get accurate world position drawn to CanvasLayer, subtract this scene's global pos
	var self_pos = _dbg.global_position
	
	var entity_tile_id = lib_tilemap.world_to_map(_dbg._tilemap, _dbg.entity.global_position)
	var entity_pos = lib_tilemap.map_to_world(_dbg._tilemap, entity_tile_id) - self_pos + _offset

	# draw visual of tile that entity's current position
	draw_tile_marker(entity_pos, _dbg.marker_size, _dbg.position_color)
	
	# draw visual of entity's destination tile
	var dest_pos = lib_tilemap.map_to_world(_dbg._tilemap, entity_tile_id + _dbg.entity.movement_vector) \
		- self_pos + _offset
	
	if entity_pos != dest_pos:
		var col = _dbg.destination_color
		if is_blocked(entity_tile_id + _dbg.entity.movement_vector):
			col = _dbg.blocked_color
		
		draw_tile_marker(dest_pos, _dbg.marker_size, col)
	
	
func _process(_delta):
	update()
