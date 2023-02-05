extends KinematicBody2D

enum CharacterState { STAND, WALK, TURN } # TODO: should this go somewhere else?

# -----------------------------------------------------------------------------
# customizable character settings
# -----------------------------------------------------------------------------
## determines how fast the character will walk
export (int) var walk_speed = 50

## delay (in seconds) between turning and walking (quick press button to turn w/o walking)
export (float) var turn_debounce_duration = 0.1

## control speed of walk animation when press and holding walk into a wall
export (float) var hitting_wall_animation_speed = 0.35

# -----------------------------------------------------------------------------
# shared character state (do not touch)
# -----------------------------------------------------------------------------
export (Vector2) var movement_vector = Vector2(0, 0)
export (CharacterState) var movement_state = CharacterState.STAND
export (lib_movement.Direction) var direction = lib_movement.Direction.SOUTH_WEST
export (lib_movement.MovementStrategy) var movement_strategy = lib_movement.MovementStrategy.UP_IS_NORTHWEST
