extends Node

## Contains utility functions for working with tilemaps

## Provided a node, get the nearest tilemap (closest ancestor) in the scene
## tree. This will return null if it cannot find a tilemap.
func get_nearest_tilemap(node):
	var map = node.get_parent()
	while map:
		if map is TileMap:
			break
		map = map.get_parent()
		
	return map

## given a node, move it to the center of the nearest tilemap cell specified by
## position. (If a position is null or not provided, snap to nearest cell)
##
## node -> node to snap
## map -> tilemap to use as snap reference
## position -> position to snap to (pass null to use node's global_position)
## offset -> optional offset to add to final position
func snap_to_tilemap(node, map, position = null, offset = Vector2(0, 0)):
	if not map:
		print("[WARNING] (lib_tilemap.snap_to_tilemap) align_to_tilemap provided invalid map")
		return
		
	if not position:
		position = node.global_position

	var tile_pos = map.world_to_map(position)
	var world_pos = map.map_to_world(tile_pos)
	
	node.global_position = world_pos + offset
