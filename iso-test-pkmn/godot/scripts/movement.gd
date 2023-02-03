extends KinematicBody2D

enum PlayerState { STAND, WALK, TURN }
enum Direction { NORTH, NORTH_WEST, WEST, SOUTH_WEST, SOUTH, SOUTH_EAST, EAST, NORTH_EAST }
enum DirectionString { N, NW, W, SW, S, SE, E, NE }

var SPEED = 50
var state = PlayerState.STAND
var velocity = Vector2(0, 0)
var prev_velocity = Vector2(INF, INF)
var destination = Vector2(0, 0)
var direction = Direction.SOUTH_WEST
var tilemap = null
onready var animation_player = $AnimationPlayer

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)


func direction_suffix_str(d):
	return str(DirectionString.keys()[int(d)]).to_lower()


func direction_to_string(d):
	return Direction.keys()[d]


func vector_to_direction(vector: Vector2, default_dir = null):
	if vector.length() == 0:
		return default_dir
		
	var dir
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
	
	return dir


func get_nearest_tilemap():
	var map = get_parent()
	while map:
		if map is TileMap:
			break
		map = map.get_parent()
		
	return map


func snap_to_tilemap(map, position = global_position):
	if not map:
		print("WARNING: align_to_tilemap provided invalid map")
		return

	var tile_pos = map.world_to_map(position)
	var world_pos = map.map_to_world(tile_pos)
	
	global_position = world_pos - $player_sprite.offset


func _ready():
	tilemap = get_nearest_tilemap()
	if tilemap:
		snap_to_tilemap(tilemap)


func _physics_process(delta):
	var anim = ""
	var anim_suffix = ""
	
	if state == PlayerState.STAND:
		velocity = Vector2(0, 0)
		
		# use elif here to explicitly disallow diagonal movement
		if Input.is_action_pressed("up"):
			velocity += Vector2(0, -1)
		elif Input.is_action_pressed("left"):
			velocity += Vector2(-1, 0)
		elif Input.is_action_pressed("right"):
			velocity += Vector2(1, 0)
		elif Input.is_action_pressed("down"):
			velocity += Vector2(0, 1)
		
		if velocity != Vector2():
			anim = "walk"
			state = PlayerState.WALK
			
			var iso_dir = cartesian_to_isometric(velocity)
			var new_dir = vector_to_direction(iso_dir, direction)
			if new_dir != direction:
				destination = tilemap.world_to_map(global_position)
				velocity = Vector2(0, 0)
				$AnimationPlayer.play("walk-" + direction_suffix_str(new_dir))
				state = PlayerState.TURN
				
				yield(get_tree().create_timer(0.1), "timeout")
				
				direction = new_dir
				
				# TODO: get rid of this with proper state machine implementation
				var key_pressed = Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")
				if key_pressed:
					$AnimationPlayer.play("walk-" + direction_suffix_str(new_dir))
				else:
					$AnimationPlayer.play("stand-" + direction_suffix_str(new_dir))
				
				return
			else:
				destination = tilemap.world_to_map(global_position) + velocity
		else:
			anim = "stand"
			state = PlayerState.STAND
	
	var motion = velocity.normalized() * SPEED * delta
	motion = cartesian_to_isometric(motion)
	
	var dest_position = tilemap.map_to_world(destination) + $player_sprite.offset
	var remaining_length = dest_position - global_position
	
	# if the destination tile is occupied, abort the move
	var against_wall = false
	if test_move(transform, remaining_length):
		destination = tilemap.world_to_map(global_position)
		remaining_length = Vector2(0, 0)
		against_wall = true
	
	if remaining_length.length() <= motion.length():
		motion = remaining_length
		anim = "stand"
		state = PlayerState.STAND
	
	var _collision_info = move_and_collide(motion)
	
	direction = vector_to_direction(cartesian_to_isometric(velocity), direction)
	anim_suffix = direction_suffix_str(direction)

	# TODO: clean this up
	var key_pressed = Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right")

	if prev_velocity != velocity:
		$AnimationPlayer.play(anim + "-" + anim_suffix);
		prev_velocity = velocity
	elif key_pressed and against_wall:
		# we are collided with something but the player is holding down the directional key for some reason
		# TODO: this conditional can be more accurate than it is now
		$AnimationPlayer.play("walk-" + anim_suffix, -1, 0.5)
		
