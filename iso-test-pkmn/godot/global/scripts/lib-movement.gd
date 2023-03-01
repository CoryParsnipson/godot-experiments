extends Node

## Explicit definition for directions. Used for character movement.
enum Direction {
	NORTH,
	NORTH_WEST,
	WEST,
	SOUTH_WEST,
	SOUTH,
	SOUTH_EAST,
	EAST,
	NORTH_EAST
}


## suffix/abbreviation for direction value. Useful to convert to string.
## It is important that the order of these values matches that of those in
## the Direction enum.
enum DirectionSuffix {
	N,
	NW,
	W,
	SW,
	S,
	SE,
	E,
	NE
}


## specify how to interpret keystrokes
##
## UP_IS_NORTHWEST -> pressing "up" will move to the upper left tile
## UP_IS_NORTHEAST -> pressing "up" will move to the upper right tile
## UP_IS_NORTH -> to move northeast requires you to press both "up" and "right"
##   keys at the same time and similarly for the other 4 cardinal directions.
##   Pressing one direction will make you move diagonally (or do nothing if
##   diagonal movement is disabled)
enum MovementStrategy {
	UP_IS_NORTHWEST,
	UP_IS_NORTHEAST,
	UP_IS_NORTH
}


## convert DirectionSuffix enum value to string
func direction_suffix_str(d):
	return str(DirectionSuffix.keys()[int(d)]).to_lower()


## Convert Direction enum value to string
func direction_to_string(d):
	return Direction.keys()[d]


## Given a vector, find the angle and convert to Direction enum value. The
## default_dir value will be returned if the vector is invalid. An invalid
## vector is one that is zero length or has an angle that is not perfectly
## aligned to an 8 directional isometric axis.
## 
## vector -> vector to convert to Direction
## default_dir -> default value to use if provided vector is zero length
func vector_to_direction(vector: Vector2, default_dir = Direction.SOUTH_WEST):
	if vector.length() == 0:
		return default_dir
		
	var dir = default_dir
	match (round(fposmod(rad2deg(vector.angle()), 360)) as int):
		0:
			dir = Direction.EAST
		27:
			dir = Direction.SOUTH_EAST
		90:
			dir = Direction.SOUTH
		153:
			dir = Direction.SOUTH_WEST
		180:
			dir = Direction.WEST
		207:
			dir = Direction.NORTH_WEST
		270:
			dir = Direction.NORTH
		333:
			dir = Direction.NORTH_EAST
		_:
			print("[WARNING] (lib_movement.vector_to_direction) Vector is not predefined direction.")
	
	return dir


## Convert direction to vector (in cartesian coordinates)
##
## This will take a direction enum value and change it to a vector of unit length.
## The convention is that 0 degrees is east and then increasing values are
## clockwise.
func direction_to_vector(direction):
	match (direction):
		Direction.EAST:
			return Vector2(1, 0)
		Direction.SOUTH_EAST:
			return Vector2(1, 1).normalized()
		Direction.SOUTH:
			return Vector2(0, 1)
		Direction.SOUTH_WEST:
			return Vector2(-1, 1).normalized()
		Direction.WEST:
			return Vector2(-1, 0)
		Direction.NORTH_WEST:
			return Vector2(-1, -1).normalized()
		Direction.NORTH:
			return Vector2(0, -1)
		Direction.NORTH_EAST:
			return Vector2(1, -1).normalized()


## Poll input and return a vector depending on which keys are pressed
func get_movement_vector(directions_pressed : Dictionary, movement_strategy, allow_diagonal: bool = false):
	var up_pressed = directions_pressed["up"]
	var left_pressed = directions_pressed["left"]
	var right_pressed = directions_pressed["right"]
	var down_pressed = directions_pressed["down"]
	
	var movement_vector = Vector2(0, 0)
	
	match (movement_strategy):
		MovementStrategy.UP_IS_NORTHWEST:
			if up_pressed:
				movement_vector += Vector2(-1, 0)
			elif down_pressed:
				movement_vector += Vector2(1, 0)
				
			if movement_vector == Vector2(0, 0) or allow_diagonal:
				if left_pressed:
					movement_vector += Vector2(0, 1)
				elif right_pressed:
					movement_vector += Vector2(0, -1)
		MovementStrategy.UP_IS_NORTHEAST:
			if up_pressed:
				movement_vector += Vector2(0, -1)
			elif down_pressed:
				movement_vector += Vector2(0, 1)
			
			if movement_vector == Vector2(0, 0) or allow_diagonal:
				if left_pressed:
					movement_vector += Vector2(-1, 0)
				elif right_pressed:
					movement_vector += Vector2(1, 0)
		MovementStrategy.UP_IS_NORTH:
			var button_mask = 0
			button_mask |= 0x1 if up_pressed else 0x0
			button_mask |= 0x2 if left_pressed else 0x0
			button_mask |= 0x4 if right_pressed else 0x0
			button_mask |= 0x8 if down_pressed else 0x0
			
			if button_mask == 0x5: # up and right pressed (go northeast)
				movement_vector = Vector2(0, -1)
			elif button_mask == 0x3: # up and left pressed (go northwest)
				movement_vector = Vector2(-1, 0)
			elif button_mask == 0xC: # down and right pressed (go southeast)
				movement_vector = Vector2(1, 0)
			elif button_mask == 0xA: # down and left pressed (go southwest)
				movement_vector = Vector2(0, 1)
			elif allow_diagonal and button_mask == 0x1: # up is pressed
				movement_vector = Vector2(-1, -1)
			elif allow_diagonal and button_mask == 0x2: # left is pressed
				movement_vector = Vector2(-1, 1)
			elif allow_diagonal and button_mask == 0x4: # right is pressed
				movement_vector = Vector2(1, -1)
			elif allow_diagonal and button_mask == 0x8:  # down is pressed
				movement_vector = Vector2(1, 1)
		
	return movement_vector
