extends Node2D

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _interaction = get_node(_interaction)


## This script is responsible for moving the interaction area to the right place based on the
## character's movement.
func _physics_process(_delta):
	var tilemap = lib_tilemap.get_nearest_tilemap(_state)
	if not tilemap:
		return
	
	# use the tilemap to find position of which tile is in front of the player
	var tile_id_delta = lib_movement.direction_to_vector(_state.direction)
	tile_id_delta = lib_isometric.isometric_to_cartesian(tile_id_delta).normalized()
	
	var dest_tile_id = lib_tilemap.world_to_map(tilemap, _state.global_position) + tile_id_delta
	var dest_pos = lib_tilemap.map_to_world(tilemap, dest_tile_id)
	var dest_pos_centered_on_tile = dest_pos + (tilemap.cell_size / 2 * Singleton.pixel_upscale * Vector2(0, 1))
	
	_interaction.global_position = dest_pos_centered_on_tile
