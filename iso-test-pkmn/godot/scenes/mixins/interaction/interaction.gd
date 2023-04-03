extends "res://scenes/mixins/mixin.gd"
class_name Interaction

enum InteractEventType { INTERACTOR_ENTERED, INTERACTOR_EXITED }

signal interact_event_occurred(type, interactor, interactable)

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _parent = get_node(_parent)
export (String) var interact_keybinding = "accept"

onready var _interaction_area = get_node_or_null("interaction-area")

var _update_pos_on_physics_process = false


func _on_interactable_entered(area):
	if not _state:
		print("[WARNING] (interaction._on_interactable_entered): entity _state node not provided")
		return
	
	if area.owner.can_interact(_parent):
		_state.interactables.push_back(area.owner)
		var _err = connect("interact_event_occurred", area.owner, "_on_interact_event")
		emit_signal(
			"interact_event_occurred",
			InteractEventType.INTERACTOR_ENTERED,
			_parent,
			area.owner.interactable_parent
		)
		
		if area.owner.interact_on_enter:
			area.owner.interact(_parent)


func _on_interactable_exited(area):
	if not _state:
		print("[WARNING] (interaction._on_interactable_entered): entity _state node not provided")
		return
	
	if not (area.owner in _state.interactables):
		return
	
	_state.interactables.erase(area.owner)
	emit_signal(
		"interact_event_occurred",
		InteractEventType.INTERACTOR_EXITED,
		_parent,
		area.owner.interactable_parent
	)
	call_deferred("disconnect", "interact_event_occurred", area.owner, "_on_interact_event")


func _update_position(_movement, _entity):
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


func _on_ready():
	_update_position(null, null) # set initial pos
	
	var mv = _parent.find_node("movement")
	if mv:
		mv.connect("turn", self, "_update_position")
		mv.connect("move", self, "_update_position")
	else:
		_update_pos_on_physics_process = true


func _on_physics_process(_delta):
	if not _update_pos_on_physics_process:
		return
		
	_update_position(null, null)
