extends Node2D

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _kinematic_body = get_node(_kinematic_body)

onready var _tilemap = lib_tilemap.get_nearest_tilemap(owner)

var _movement_vector = Vector2(0, 0)
var _destination = Vector2(0, 0)

## set a map tile coordinate to move this character towards.
func set_destination(map, movement_vector):
	if not map:
		print("[WARNING] (movement.set_destination) invalid tilemap node provided")
		return
			
	_destination = map.world_to_map(_kinematic_body.global_position) + movement_vector
	_movement_vector = movement_vector


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
	
	
func _ready():
	# on load, align this thing to the tilemap
	lib_tilemap.snap_to_tilemap(_kinematic_body, _tilemap)


func _physics_process(delta):
	if _state.movement_state == _state.CharacterState.STAND:
		var movement_vector = lib_movement.get_input(_state.movement_strategy)
		if movement_vector != Vector2(0, 0):
			set_destination(_tilemap, movement_vector)
			_state.movement_state = _state.CharacterState.WALK
	elif _state.movement_state == _state.CharacterState.WALK:
		var move_finished = move_to_tile(_tilemap, _movement_vector, _destination, delta)
		if move_finished:
			set_destination(_tilemap, Vector2(0, 0))
			_state.movement_state = _state.CharacterState.STAND
	elif _state.movement_state == _state.CharacterState.TURN:
		pass
	else:
		print("[WARNING] (character._physics_process) character is in an invalid state")
