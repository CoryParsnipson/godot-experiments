extends KinematicBody2D

enum CharacterState { STAND, WALK, TURN }

## determines how fast the character will walk
export (int) var walk_speed = 50
export (lib_movement.Direction) var direction = lib_movement.Direction.SOUTH_WEST
export (lib_movement.MovementStrategy) var movement_strategy = lib_movement.MovementStrategy.UP_IS_NORTHWEST
export (CharacterState) var movement_state = CharacterState.STAND
