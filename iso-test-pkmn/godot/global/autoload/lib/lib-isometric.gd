extends Node

## project from cartesian coordinates to isometric
##
## cartesian -> Vector2() of cartesian coordinates to convert to isometric coordinates
func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)


## project from isometric coordinates to cartesian
##
## isometric -> Vector2() of isometric coordinates to convert to cartesian coordinates
func isometric_to_cartesian(isometric):
	var cartesian = Vector2()
	cartesian.x = (isometric.x + isometric.y) / 2
	cartesian.y = cartesian.x - isometric.x
	return cartesian


## given a direction that is made from a cartesian vector, return the equivelant
## direction that an isometric vector would have made
##
## cartesian_direction -> lib_movement.Direction to convert to isometric
## movement_strategy -> lib_movement.MovementStrategy to use
##
## Returns a lib_movement.Direction object
func isometric_direction(cartesian_direction, movement_strategy):
	if movement_strategy == lib_movement.MovementStrategy.UP_IS_NORTH:
		# UP_IS_NORTH is real direction, no conversion needed
		return cartesian_direction
	
	var cartesian_vector = lib_movement.direction_to_vector(cartesian_direction)
	var iso_vector = cartesian_vector.rotated(
		deg2rad(45
			if movement_strategy == lib_movement.MovementStrategy.UP_IS_NORTHEAST
			else -45
		)
	)
	
	return lib_movement.vector_to_direction(iso_vector)
