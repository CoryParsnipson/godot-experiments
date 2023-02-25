extends KinematicBody2D

enum CharacterState { STAND, WALK, TURN } # TODO: should this go somewhere else?

# -----------------------------------------------------------------------------
# customizable character settings
# -----------------------------------------------------------------------------
## enable/disable walking diagonally (false means only allow 4 cardinal dir)
export (bool) var allow_diagonal = false

## determines how fast the character will walk
export (int) var walk_speed = 150

## delay (in seconds) between turning and walking (quick press button to turn w/o walking)
export (float) var turn_debounce_duration = 0.2

## control speed of walk animation when press and holding walk into a wall
export (float) var hitting_wall_animation_speed = 0.35

# -----------------------------------------------------------------------------
# shared character state (do not touch)
# -----------------------------------------------------------------------------
export (Vector2) var movement_vector = Vector2(0, 0)
export (CharacterState) var movement_state = CharacterState.STAND
export (lib_movement.Direction) var direction = lib_movement.Direction.SOUTH_WEST
export (lib_movement.MovementStrategy) var movement_strategy = lib_movement.MovementStrategy.UP_IS_NORTHWEST

# -----------------------------------------------------------------------------
# interactables
# -----------------------------------------------------------------------------
export (Array, NodePath) var interactables = []
