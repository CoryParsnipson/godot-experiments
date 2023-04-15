extends "res://scenes/mixins/mixin.gd"

signal pre_move(movement, entity)
signal post_move(movement, entity)
signal move(movement, entity)
signal turn(movement, entity)

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _kinematic_body = get_node(_kinematic_body)
export (NodePath) onready var _animations = get_node(_animations)

onready var _tilemap = lib_tilemap.get_nearest_tilemap(owner)
onready var _turn_debounce_timer = $"turn_debounce_timer"

var _movement_vector = Vector2(0, 0)
var _destination = Vector2(0, 0)
var _is_turning = false
var _move_cancelled = false
var _movement_against_wall_emitted = null
var _last_animation_played = ""
var _last_animation_speed = 1.0


## Begin a move for this character to a map tile specified by movement_vector.
##
## Begin a move. The actual move is processed by move_to_tile() over the course
## of many frames via _physics_process. This function saves the movement_vector
## and destination to state. (_movement_vector and _destination, respectively).
## 
## movement_vector -> Vector2() delta to move. I.e. Vector(-1, 1) means move
##   one tile to the left on x axis and one tile down on y axis.
## map -> tilemap to use as reference
func set_destination(movement_vector, map = _tilemap):
	if not map:
		print("[WARNING] (movement.set_destination) invalid tilemap node provided")
		return
	
	_destination = lib_tilemap.world_to_map(map, _kinematic_body.global_position) + movement_vector
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
func get_direction_from_movement_vector(movement_vector):
	return lib_isometric.isometric_direction(
		lib_movement.vector_to_direction(movement_vector, get_direction()),
		_state.movement_strategy
	)


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
	
	var remaining_length = lib_tilemap.map_to_world(map, dest) - _kinematic_body.global_position
	
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
	
	var remaining_length = lib_tilemap.map_to_world(map, dest) - _kinematic_body.global_position
	return _kinematic_body.test_move(_kinematic_body.global_transform, remaining_length)


## Play animation. This checks the last animation flag and does not call the
## animation player if the two match.
##
## animation_player -> reference to AnimationPlayer component
## anim_string -> string containing name of animation to play
## custom_blend -> float for custom blend parameter of AnimationPlayer.play()
## custom_speed -> float for custom speed parameter of AnimationPlayer.play()
func _play_animation(animation_player, anim_string, custom_blend = -1, custom_speed = 1.0):
	if anim_string == _last_animation_played and custom_speed == _last_animation_speed:
		return
	
	# if the AnimationPlayer reference uses animation tracks, setting a custom speed during
	# play() will not affect the reference animation track. So as a workaround, iterate
	# through all the children of animation player and set the speed to custom_speed
	var players = []
	players.append_array(animation_player.get_children())
	while (players.size() > 0):
		players.append_array(players.front().get_children())
		if players.front() is AnimationPlayer:
			players.front().playback_speed = custom_speed
		players.pop_front()
	
	animation_player.play(anim_string, custom_blend, custom_speed)
	_last_animation_played = anim_string
	_last_animation_speed = custom_speed


## This will cancel any movement that is in progress and set the character state
## to STAND.
##
## emit_post_move -> bool; if true, will emit the post_move signal on cancel
## snap_to_tilemap -> bool; if true, will snap to nearest tile on cancel
func cancel_movement(emit_post_move = false, snap_to_tilemap = false):
	set_destination(Vector2(0, 0))
	_movement_vector = Vector2(0, 0)
	_state.movement_vector = _movement_vector
	_state.movement_state = lib_movement.MoveState.STAND
	_play_animation(_animations, lib_movement.get_animation_id(lib_movement.MoveState.STAND, get_direction()))
	_move_cancelled = true
	
	if emit_post_move:
		emit_signal("post_move", self, _state)
	
	if snap_to_tilemap:
		lib_tilemap.snap_to_tilemap(_kinematic_body, _tilemap)


func _on_enable_changed_hook(new_enable):
	if not _state:
		return
	_state.is_moving_against_wall = false


func _emit_pre_movement_signal():
	emit_signal("pre_move", self, _state)
	_movement_against_wall_emitted = null


func _emit_movement_signal():
	if _state.is_moving_against_wall:
		var dir = get_direction()
		if not _movement_against_wall_emitted or _movement_against_wall_emitted != dir:
			emit_signal("move", self, _state)
			_movement_against_wall_emitted = dir
	else:
		emit_signal("move", self, _state)
		_movement_against_wall_emitted = null


func _emit_post_movement_signal():
	emit_signal("post_move", self, _state)


func _emit_turn_signal():
	emit_signal("turn", self, _state)


## Handle movement events when turn_debounce_timer ends
##
## When the timer expires, the movement script needs to poll input again to 
## determine if the user, who has just pressed a key that causes the player to
## change direction is still holding it down. If not, then this was just a turn
## (no tile movement involved). Else, then we need to immediately transition
## into walking state.
func _on_turn_debounce_timeout():
	_is_turning = false
	
	# check movement vector and decide if we need to react to anything
	if _state.movement_vector.length() == 0:
		_state.movement_state = lib_movement.MoveState.STAND
	else:
		var new_direction = get_direction_from_movement_vector(_state.movement_vector)
		var curr_direction = get_direction()

		if new_direction == curr_direction:
			set_destination(_state.movement_vector)
			_state.movement_state = lib_movement.MoveState.WALK
		elif new_direction != curr_direction:
			_state.movement_state = lib_movement.MoveState.TURN


func _on_ready():
	# initialize some stuff
	_turn_debounce_timer.wait_time = _state.turn_debounce_duration
		
	# on load, align this thing to the tilemap
	lib_tilemap.snap_to_tilemap(_kinematic_body, _tilemap)
	
	# initialize animation
	_play_animation(_animations, lib_movement.get_animation_id(lib_movement.MoveState.STAND, get_direction()))


func _on_physics_process(delta):
	# check movement vector and decide if we need to react to anything
	var new_direction = get_direction_from_movement_vector(_state.movement_vector)
	_state.is_moving_against_wall = false
	
	if _state.movement_state == lib_movement.MoveState.STAND:
		_emit_pre_movement_signal()
		if _move_cancelled:
			_move_cancelled = false
			return
		
		_play_animation(_animations, lib_movement.get_animation_id(lib_movement.MoveState.STAND, get_direction()))
		
		# player is standing and not pressing keys, do nothing
		if _state.movement_vector == Vector2(0, 0):
			return
		
		# player is standing and key is pressed in new direction
		if new_direction != get_direction():
			_state.movement_state = lib_movement.MoveState.TURN
			return
		
		# key is pressed in same direction we are currently facing
		set_destination(_state.movement_vector)
		_state.movement_state = lib_movement.MoveState.WALK

	elif _state.movement_state == lib_movement.MoveState.WALK:
		if _movement_vector.length() == 0:
			print("[WARNING] movement.physics_process: entered WALK state with zero length movement vector. This should not be possible.")
			_state.movement_state = lib_movement.MoveState.STAND
			return
		
		if _move_cancelled:
			_move_cancelled = false
			_state.movement_state = lib_movement.MoveState.STAND
			return
		
		# NOTE: if the character is following another character one tile behind
		# but both are moving at the same speed, this function will return true,
		# incorrectly. Not sure how to fix...
		_state.is_moving_against_wall = is_against_wall(_tilemap, _destination)
		if _state.is_moving_against_wall:
			# play walk animation at slow speed when against wall
			_play_animation(
				_animations,
				lib_movement.get_animation_id(lib_movement.MoveState.WALK, get_direction()),
				-1,
				_state.hitting_wall_animation_speed
			)
		else:
			_play_animation(_animations, lib_movement.get_animation_id(lib_movement.MoveState.WALK, get_direction()))
		
		# execute movement, ignore user input unless the movement finishes
		var move_finished = move_to_tile(_tilemap, _movement_vector, _destination, delta)
		if not move_finished:
			return
			
		# move is done and no keys pressed, so go back to standing	
		if _state.movement_vector.length() == 0:
			_emit_movement_signal()
			set_destination(Vector2(0, 0))
			_state.movement_state = lib_movement.MoveState.STAND
			_emit_post_movement_signal()
			return
		
		# keys are pressed and there is a direction change
		if new_direction != get_direction():
			set_direction(new_direction)
			set_destination(_state.movement_vector)
			_emit_movement_signal()
			return
		
		# keys are pressed, but no direction change. Continue walking
		set_destination(_state.movement_vector)
		_emit_movement_signal()
			
	elif _state.movement_state == lib_movement.MoveState.TURN:
		if _is_turning:
			return
		
		_is_turning = true
		set_direction(new_direction)
		_play_animation(_animations, lib_movement.get_animation_id(lib_movement.MoveState.WALK, get_direction()))
		_turn_debounce_timer.start()
		
		_emit_turn_signal()

	else:
		print("[WARNING] (character._physics_process) character is in an invalid state")
