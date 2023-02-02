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


func vector_to_direction(vector: Vector2):
	if vector.length() == 0:
		return direction
		
	match (round(fposmod(rad2deg(vector.angle()), 360)) as int):
		0:
			direction = Direction.EAST
		27:
			direction = Direction.SOUTH_EAST
		90:
			direction = Direction.SOUTH
		153:
			direction = Direction.SOUTH_WEST
		180:
			direction = Direction.WEST
		207:
			direction = Direction.NORTH_WEST
		270:
			direction = Direction.NORTH
		333:
			direction = Direction.NORTH_EAST


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
		if Input.is_action_pressed("up"):
			velocity += Vector2(0, -1)
		
		if Input.is_action_pressed("left"):
			velocity += Vector2(-1, 0)
			
		if Input.is_action_pressed("right"):
			velocity += Vector2(1, 0)
			
		if Input.is_action_pressed("down"):
			velocity += Vector2(0, 1)
		
		if velocity != Vector2():
			anim = "walk"
			state = PlayerState.WALK
			destination = tilemap.world_to_map(global_position) + velocity
		else:
			anim = "stand"
			state = PlayerState.STAND
	
	var motion = velocity.normalized() * SPEED * delta
	motion = cartesian_to_isometric(motion)
	
	var dest_position = tilemap.map_to_world(destination) + $player_sprite.offset
	var remaining_length = dest_position - global_position
	
	if remaining_length.length() <= motion.length():
		motion = remaining_length
		anim = "stand"
		state = PlayerState.STAND
	
	move_and_collide(motion) # TODO: handle collision
	
	vector_to_direction(velocity)
	match (direction):
		Direction.NORTH:
			anim_suffix = "ne"
		Direction.SOUTH:
			anim_suffix = "sw"
		Direction.EAST:
			anim_suffix = "se"
		Direction.WEST:
			anim_suffix = "nw"
		Direction.NORTH_EAST:
			anim_suffix = "ne"
		Direction.NORTH_WEST:
			anim_suffix = "nw"
		Direction.SOUTH_EAST:
			anim_suffix = "se"
		Direction.SOUTH_WEST:
			anim_suffix = "sw"

	if prev_velocity != velocity:
		$AnimationPlayer.play(anim + "-" + anim_suffix);
		prev_velocity = velocity
