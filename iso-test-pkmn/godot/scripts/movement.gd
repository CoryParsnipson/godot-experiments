extends KinematicBody2D

enum Direction { NORTH, NORTH_WEST, WEST, SOUTH_WEST, SOUTH, SOUTH_EAST, EAST, NORTH_EAST }
enum DirectionString { N, NW, W, SW, S, SE, E, NE }

var SPEED = 50
var motion = Vector2(0, 0)
var velocity = Vector2(0, 0)
var prev_velocity = Vector2(INF, INF)
var direction = Direction.SOUTH_WEST
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


func _physics_process(delta):
	var anim = ""
	var anim_suffix = ""
	
	velocity = Vector2(0, 0)
	
	if Input.is_action_pressed("up"):
		velocity += Vector2(0, -1)
	
	if Input.is_action_pressed("left"):
		velocity += Vector2(-1, 0)
		
	if Input.is_action_pressed("right"):
		velocity += Vector2(1, 0)
		
	if Input.is_action_pressed("down"):
		velocity += Vector2(0, 1)
	
	motion = velocity.normalized() * SPEED * delta
	motion = cartesian_to_isometric(motion)
	move_and_collide(motion)
	
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

	if velocity.length() == 0:
		anim = "stand"
	else:
		anim = "walk"

	if prev_velocity != velocity:
		$AnimationPlayer.play(anim + "-" + anim_suffix);
		prev_velocity = velocity
