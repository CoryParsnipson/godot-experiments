extends Node2D

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _kinematic_body = get_node(_kinematic_body)
export (NodePath) onready var _animations = get_node(_animations)

onready var _tilemap = lib_tilemap.get_nearest_tilemap(owner)

var _movement_vector = Vector2(0, 0)
var _destination = Vector2(0, 0)


## Begin a move for this character to a map tile specified by movement_vector.
##
## Begin a move. The actual move is processed by move_to_tile() over the course
## of many frames via _physics_process. This function saves the movement_vector
## and destination to state. (_movement_vector and _destination, respectively).
## 
## map -> tilemap to use as reference
## movement_vector -> Vector2() delta to move. I.e. Vector(-1, 1) means move
##   one tile to the left on x axis and one tile down on y axis.
func set_destination(map, movement_vector):
	if not map:
		print("[WARNING] (movement.set_destination) invalid tilemap node provided")
		return
			
	_destination = map.world_to_map(_kinematic_body.global_position) + movement_vector
	_movement_vector = movement_vector


## Set the current facing direction in the character's state.
##
## new_direction -> lib_movement.Direction enum value to write
func set_direction(new_direction):
	_state.direction = new_direction


## Get the current facing direction from the character's state.
func get_direction():
	return _state.direction


## Get a lib_movement.Direction based on a movement vector
##
## movement_vector -> Vector2() delta from lib_movement.get_input()
func get_new_direction(movement_vector):
	var iso_movement_vector = lib_isometric.cartesian_to_isometric(movement_vector)
	return lib_movement.vector_to_direction(iso_movement_vector, get_direction())


## Move this character to the specified cell in a tilemap.
##
## Moves the character (kinematic body) to the middle of the cell specified by
## the dest parameter. This function is supposed to run once every
## _physics_process until the move is complete. The caller code must manage
## this. This function returns false if the move is still in progress and then
## returns true if the move is complete or aborted due to collision.
##
## map -> the tilemap to base calculations for cell alignment
## movement_vector -> movement_vector associated with this move
## dest -> destination tile coordinate of tilemap
## delta -> time delta float of _process or _physics_process
func move_to_tile(map, movement_vector, dest, delta):
	if not map:
		print("[WARNING] (movement.move_to_tile) invalid tilemap node provided")
		return true
	
	var motion = movement_vector.normalized() * _state.walk_speed * delta
	motion = lib_isometric.cartesian_to_isometric(motion)
	
	var remaining_length = map.map_to_world(dest) - _kinematic_body.global_position
	
	# test for collision, abort move if the destination tile is occupied
	if _kinematic_body.test_move(_kinematic_body.transform, remaining_length): 
		return true
	
	# handle if we need to stop this frame
	var move_finished = false
	if remaining_length.length() <= motion.length():
		motion = remaining_length
		move_finished = true
		
	var _collision_info = _kinematic_body.move_and_collide(motion)
	return move_finished


## Generate the name of an animation based on character state and direction
## state values.
##
## character_state -> a CharacterState enum value (e.g. WALK, STAND)
## direction -> a lib_movement.Direction enum value (e.g. NORTH_WEST, etc)
func make_anim_string(character_state, direction):
	# TODO: move this conversion code into a library?
	var state_string = str(_state.CharacterState.keys()[character_state]).to_lower()
	return state_string + "-" + lib_movement.direction_suffix_str(direction)


func _ready():
	# on load, align this thing to the tilemap
	lib_tilemap.snap_to_tilemap(_kinematic_body, _tilemap)
	
	# initialize animation
	_animations.play(make_anim_string(_state.CharacterState.STAND, get_direction()))


func _physics_process(delta):
	# poll user input and decide if we need to react to anything
	var input_vector = lib_movement.get_input(_state.movement_strategy)
	var new_direction = get_new_direction(input_vector)
	
	if _state.movement_state == _state.CharacterState.STAND:
		# player is standing and not pressing keys, do nothing
		if input_vector == Vector2(0, 0):
			return
			
		# player is standing and key is pressed in new direction
		if new_direction != get_direction():
			_state.movement_state = _state.CharacterState.TURN
			return
		
		# key is pressed in same direction we are currently facing
		set_destination(_tilemap, input_vector)
		_animations.play(make_anim_string(_state.CharacterState.WALK, get_direction()))
		_state.movement_state = _state.CharacterState.WALK

	elif _state.movement_state == _state.CharacterState.WALK:
		# execute movement, ignore user input unless the movement finishes
		var move_finished = move_to_tile(_tilemap, _movement_vector, _destination, delta)
		if not move_finished:
			return
			
		# move is done and no keys pressed, so go back to standing	
		if input_vector == Vector2(0, 0):
			set_destination(_tilemap, Vector2(0, 0))
			_animations.play(make_anim_string(_state.CharacterState.STAND, get_direction()))
			_state.movement_state = _state.CharacterState.STAND
			return
			
		# keys are pressed and there is a direction change, go to turn state
		if new_direction != get_direction():
			_state.movement_state = _state.CharacterState.TURN
			return
			
		# keys are pressed, but no direction change. Continue walking
		set_destination(_tilemap, input_vector)
			
	elif _state.movement_state == _state.CharacterState.TURN:
		# TODO: implement turning
		set_direction(new_direction)
		_state.movement_state = _state.CharacterState.STAND

	else:
		print("[WARNING] (character._physics_process) character is in an invalid state")
