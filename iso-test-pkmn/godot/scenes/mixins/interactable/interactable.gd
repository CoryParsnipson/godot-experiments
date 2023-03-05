extends "res://scenes/mixins/mixin.gd"

export (bool) var interactable_east
export (bool) var interactable_southeast
export (bool) var interactable_south
export (bool) var interactable_southwest
export (bool) var interactable_west
export (bool) var interactable_northwest
export (bool) var interactable_north
export (bool) var interactable_northeast

export (NodePath) onready var interactable_parent = get_node(interactable_parent)


func _get_direction_of_interactor(interactor):
	var interactable_map = lib_tilemap.get_nearest_tilemap(interactable_parent)
	var interactor_map = lib_tilemap.get_nearest_tilemap(interactor)

	var interactable_tile_id = lib_tilemap.world_to_map(interactable_map, $"interactable-area".global_position)
	var interactor_tile_id = lib_tilemap.world_to_map(interactor_map, interactor.global_position)

	# get the tilemap coordinates of both objects and then get direction
	# based on difference in coordinates
	var delta = interactor_tile_id - interactable_tile_id
	delta = lib_isometric.cartesian_to_isometric(delta)
	
	return lib_movement.vector_to_direction(delta, null)


func _can_interact_from_direction(direction):
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
	if not _can_interact_from_direction(_get_direction_of_interactor(interactor)):
		return false
	
	if interactable_parent and interactable_parent.has_method("can_interact"):
		return interactable_parent.can_interact(interactor)
	
	print("[WARNING] (interactable.can_interact): interactable does not have can_interact() defined.")
	return false


func interact(interactor : Node):
	if interactable_parent and interactable_parent.has_method("interact"):
		return interactable_parent.interact(interactor)
	
	print("[WARNING] (interactable.interact): interactable does not have interact() defined.")\
