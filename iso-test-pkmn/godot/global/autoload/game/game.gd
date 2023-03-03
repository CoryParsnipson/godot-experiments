extends Node

# -----------------------------------------------------------------------------
# game state defines
# -----------------------------------------------------------------------------
enum InputState { NORMAL, DIALOGUE, CUTSCENE }

# -----------------------------------------------------------------------------
# global config
# -----------------------------------------------------------------------------
## enable all debug entities and visualizations
export (bool) var debug_enable = true

## context for whether or not to allow input
export (InputState) var input_state = InputState.NORMAL

## enlarge game assets (this scales all non-UI game nodes)
export (Vector2) var pixel_upscale = Vector2(3, 3)

# -----------------------------------------------------------------------------
# services
# -----------------------------------------------------------------------------
## dialogue manager (used to operate dialogue boxes)
export (NodePath) onready var dialogue_manager = get_node(dialogue_manager)
