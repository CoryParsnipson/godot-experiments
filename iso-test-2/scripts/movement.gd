extends KinematicBody2D

export (NodePath) onready var map = get_node(map)
export (NodePath) onready var debug_direction = get_node(debug_direction)
export (int) var areaLayer = 2
export (int) var speed = 100

export (bool) var onStairs = false

enum Direction { NORTH, NORTH_WEST, WEST, SOUTH_WEST, SOUTH, SOUTH_EAST, EAST, NORTH_EAST }
enum DirectionString { N, NW, W, SW, S, SE, E, NE }

var velocity = Vector2()
var prev_velocity = Vector2()
var direction = Direction.EAST
var playerTransform
var globalPlayerTransform


func set_direction_label(d):
	debug_direction.text = str(DirectionString.keys()[int(d)])


func vector_to_direction(vector: Vector2):
	if vector.length() == 0:
		set_direction_label(direction)
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
	
	set_direction_label(direction)
	

func _ready():
	playerTransform = get_parent().transform
	globalPlayerTransform = get_parent().global_transform
	vector_to_direction(velocity)
	
	# initialize the map
	for zlevel in map.get_children():
		var playerOnLayer = zlevel.get_node_or_null("main/Player") != null
				
		if zlevel.get("hideOnLeave") && !playerOnLayer:
			zlevel.hide()
		
		for trigger in zlevel.get_node("triggers").get_children():
			trigger.set_collision_mask_bit(areaLayer - 1, playerOnLayer)
			trigger.set_collision_layer_bit(areaLayer - 1, playerOnLayer)


func _process(_delta):
	var anim = ""
	var anim_suffix = ""
	
	match (direction):
		Direction.NORTH:
			anim_suffix = "n"
		Direction.SOUTH:
			anim_suffix = "s"
		Direction.EAST:
			anim_suffix = "e"
		Direction.WEST:
			anim_suffix = "w"
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
		anim = "run"

	if prev_velocity != velocity:
		$AnimationPlayer.play(anim + "-" + anim_suffix);
		prev_velocity = velocity


func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("move-up"):
		velocity.y -= 0.5
	if Input.is_action_pressed("move-left"):
		velocity.x -= 1
	if Input.is_action_pressed("move-right"):
		velocity.x += 1
	if Input.is_action_pressed("move-down"):
		velocity.y += 0.5
		
	velocity = velocity.normalized() * speed
	vector_to_direction(velocity)


func _physics_process(delta):
	get_input()
	# This fix brought to you by: https://github.com/godotengine/godot/issues/18433
	# The comment at the bottom by manglemix works and is used below.
	#
	# Small modification made to if statement to check for non-zero velocity vector
	# else the call to normalized() will fail
	if (!velocity):
		return

	if (onStairs):
		var addedForce = Vector2(0, 0)
		
		if (direction == Direction.NORTH_EAST):
			addedForce = Vector2(0, -1) * speed
		elif (direction == Direction.SOUTH_WEST):
			addedForce = Vector2(0, 1) * speed
	
		velocity = (velocity + addedForce).normalized() * speed
	
	var collision_info = move_and_collide(velocity * delta)
	if (collision_info):
		global_transform.origin -= collision_info.travel.slide(velocity.normalized())
