extends "res://scenes/mixins/mixin.gd"

export (bool) var interactable_east = true
export (bool) var interactable_southeast = true
export (bool) var interactable_south = true
export (bool) var interactable_southwest = true
export (bool) var interactable_west = true
export (bool) var interactable_northwest = true
export (bool) var interactable_north = true
export (bool) var interactable_northeast = true

export (bool) var interact_on_enter = false

export (NodePath) onready var interactable_parent = get_node(interactable_parent)


func _can_interact_from_direction(direction):
	if not direction:
		return false
	
	match(direction):
		lib_movement.Direction.EAST:
			return interactable_east
		lib_movement.Direction.SOUTH_EAST:
			return interactable_southeast
		lib_movement.Direction.SOUTH:
			return interactable_south
		lib_movement.Direction.SOUTH_WEST:
			return interactable_southwest
		lib_movement.Direction.WEST:
			return interactable_west
		lib_movement.Direction.NORTH_WEST:
			return interactable_northwest
		lib_movement.Direction.NORTH:
			return interactable_north
		lib_movement.Direction.NORTH_EAST:
			return interactable_northeast


func can_interact(interactor : Node) -> bool:
	var d = lib_tilemap.get_direction_of_entity($"interactable-area", interactor)
	if not _can_interact_from_direction(d):
		return false
	
	if interactable_parent and interactable_parent.has_method("can_interact"):
		return interactable_parent.can_interact(interactor)
	
	print("[WARNING] (interactable.can_interact): interactable does not have can_interact() defined.")
	return false


func interact(interactor : Node):
	if interactable_parent and interactable_parent.has_method("interact"):
		return interactable_parent.interact(interactor)
	
	print("[WARNING] (interactable.interact): interactable does not have interact() defined.")


func _on_interact_event(event, interactor, interactable):
	if interactable_parent and interactable_parent.has_method("_on_interact_event"):
		return interactable_parent._on_interact_event(event, interactor, interactable)
