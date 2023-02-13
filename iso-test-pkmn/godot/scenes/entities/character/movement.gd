extends Node2D

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _kinematic_body = get_node(_kinematic_body)
export (NodePath) onready var _animations = get_node(_animations)
export (NodePath) onready var _turn_debounce_timer = get_node(_turn_debounce_timer)

onready var _tilemap = lib_tilemap.get_nearest_tilemap(owner)

var _movement_vector = Vector2(0, 0)
var _destination = Vector2(0, 0)
var _is_turning = false


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
			
	_destination = map.world_to_map(map.to_local(_kinematic_body.global_position)) + movement_vector
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
	
	var remaining_length = map.to_global(map.map_to_world(dest)) - _kinematic_body.global_position
	
	# test for collision, abort move if the destination tile is occupied
	if _kinematic_body.test_move(_kinematic_body.global_transform, remaining_length): 
		return true
	
	# handle if we need to stop this frame
	var move_finished = false
	if remaining_length.length() <= motion.length():
		motion = remaining_length
		move_finished = true
		
	var _collision_info = _kinematic_body.move_and_collide(motion)
	return move_finished


## Check if character is next to a wall tile on the "movement_vector" side
## 
## Given a destination, do a test move to see if the move would result in
## a collision. If it will, then we are "against a wall". This is meant to be
## used in conjunction with get_input() to determine if the player is holding
## down a button to have the character walk into a wall.
##
## map -> tilemap with which to base movement calculations
## dest -> intended movement area to test for collisions against
func is_against_wall(map, dest):
	if not map:
		print("[WARNING] (movement.is_against_wall) invalid tilemap node provided")
		return false
	
	var remaining_length = map.to_global(map.map_to_world(dest)) - _kinematic_body.global_position
	return _kinematic_body.test_move(_kinematic_body.global_transform, remaining_length)


## Generate the name of an animation based on character state and direction
## state values.
##
## character_state -> a CharacterState enum value (e.g. WALK, STAND)
## direction -> a lib_movement.Direction enum value (e.g. NORTH_WEST, etc)
func make_anim_string(character_state, direction):
	# TODO: move this conversion code into a library?
	var state_string = str(_state.CharacterState.keys()[character_state]).to_lower()
	return state_string + "-" + lib_movement.direction_suffix_str(direction)


## Handle movement events when turn_debounce_timer ends
##
## When the timer expires, the movement script needs to poll input again to 
## determine if the user, who has just pressed a key that causes the player to
## change direction is still holding it down. If not, then this was just a turn
## (no tile movement involved). Else, then we need to immediately transition
## into walking state. Conveniently, if we just transition to STAND state, the
## state machine polls for input and sets everything up for us. (Just to
## clarify this behavior in case it is confusing later...)
func _on_turn_debounce_timeout():
	_is_turning = false
	_state.movement_state = _state.CharacterState.STAND
	

func _ready():
	# initialize some stuff
	_turn_debounce_timer.wait_time = _state.turn_debounce_duration
	
	# on load, align this thing to the tilemap
	lib_tilemap.snap_to_tilemap(_kinematic_body, _tilemap)
	
	# initialize animation
	_animations.play(make_anim_string(_state.CharacterState.STAND, get_direction()))


func _physics_process(delta):
	# check movement vector and decide if we need to react to anything
	var new_direction = get_new_direction(_state.movement_vector)
	
	if _state.movement_state == _state.CharacterState.STAND:
		# player is standing and not pressing keys, do nothing
		if _state.movement_vector == Vector2(0, 0):
			_animations.play(make_anim_string(_state.CharacterState.STAND, get_direction()))
			return
			
		# player is standing and key is pressed in new direction
		if new_direction != get_direction():
			_state.movement_state = _state.CharacterState.TURN
			return
		
		# key is pressed in same direction we are currently facing
		set_destination(_tilemap, _state.movement_vector)
		_animations.play(make_anim_string(_state.CharacterState.WALK, get_direction()))
		_state.movement_state = _state.CharacterState.WALK

	elif _state.movement_state == _state.CharacterState.WALK:
		# execute movement, ignore user input unless the movement finishes
		var move_finished = move_to_tile(_tilemap, _movement_vector, _destination, delta)
		if not move_finished:
			return
			
		# move is done and no keys pressed, so go back to standing	
		if _state.movement_vector == Vector2(0, 0):
			set_destination(_tilemap, Vector2(0, 0))
			_animations.play(make_anim_string(_state.CharacterState.STAND, get_direction()))
			_state.movement_state = _state.CharacterState.STAND
			return
			
		# keys are pressed and there is a direction change, go to turn state
		if new_direction != get_direction():
			_state.movement_state = _state.CharacterState.TURN
			return
			
		# keys are pressed, but no direction change. Continue walking
		set_destination(_tilemap, _state.movement_vector)
		
		# NOTE: if the character is following another character one tile behind
		# but both are moving at the same speed, this function will return true,
		# incorrectly. Not sure how to fix...
		if is_against_wall(_tilemap, _destination):
			# play walk animation at half speed
			_animations.play(
				make_anim_string(_state.CharacterState.WALK,
				get_direction()),
				-1,
				_state.hitting_wall_animation_speed
				)
			
	elif _state.movement_state == _state.CharacterState.TURN:
		if _is_turning:
			return
			
		_is_turning = true
		set_direction(new_direction)
		_animations.play(make_anim_string(_state.CharacterState.WALK, get_direction()))
		_turn_debounce_timer.start() # transitions to STAND state in _on_turn_debounce_timeout()

	else:
		print("[WARNING] (character._physics_process) character is in an invalid state")
