extends "res://scenes/mixins/mixin.gd"

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _parent = get_node(_parent)
export (String) var interact_keybinding = "accept"

onready var _interaction_area = get_node_or_null("interaction-area")


func _on_interactable_entered(area):
	if not _state:
		print("[WARNING] (interaction._on_interactable_entered): entity _state node not provided")
		return
	
	if area.owner.can_interact(_parent):
		_state.interactables.push_back(area.owner.interactable_parent)


func _on_interactable_exited(area):
	if not _state:
		print("[WARNING] (interaction._on_interactable_entered): entity _state node not provided")
		return
	
	_state.interactables.erase(area.owner.interactable_parent)


func _physics_process(_delta):
	# use the tilemap to find position of which tile is in front of the player
	# and move the interaction area to that tile
	var tilemap = lib_tilemap.get_nearest_tilemap(_state)
	if not tilemap:
		return
	
	var tile_id_delta = lib_movement.direction_to_vector(_state.direction)
	tile_id_delta = lib_isometric.isometric_to_cartesian(tile_id_delta).normalized()
	
	var dest_tile_id = lib_tilemap.world_to_map(tilemap, _state.global_position) + tile_id_delta
	var dest_pos = lib_tilemap.map_to_world(tilemap, dest_tile_id)
	var dest_pos_centered_on_tile = dest_pos + (tilemap.cell_size / 2 * game.pixel_upscale * Vector2(0, 1))
	
	if (_interaction_area):
		_interaction_area.global_position = dest_pos_centered_on_tile

