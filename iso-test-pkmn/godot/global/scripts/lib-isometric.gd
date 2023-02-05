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
