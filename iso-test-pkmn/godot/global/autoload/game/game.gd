extends Node

# -----------------------------------------------------------------------------
# game state defines
# -----------------------------------------------------------------------------
enum InputMode { GAMEPLAY, DIALOGUE, CUTSCENE }
enum DialogueBoxType { NORMAL, SIGN }

# -----------------------------------------------------------------------------
# global config
# -----------------------------------------------------------------------------
## enable all debug entities and visualizations
export (bool) var debug_enable = true

## context for whether or not to allow input
export (InputMode) var input_mode = InputMode.GAMEPLAY

## enlarge game assets (this scales all non-UI game nodes)
export (Vector2) var pixel_upscale = Vector2(3, 3)

# -----------------------------------------------------------------------------
# services
# -----------------------------------------------------------------------------
## level root (where the levels are stored in the main scene)
export (NodePath) var level_root

## screen wipe UI element
export (NodePath) var screen_wipe

## dialogue manager (used to operate dialogue boxes)
export (NodePath) onready var dialogue = get_node(dialogue)

# -----------------------------------------------------------------------------
# game library functions
# -----------------------------------------------------------------------------

## set the game.input_mode variable to the value specified and return the
## previous value of input_mode. There is no difference between directly
## setting input and using this function, other than syntactical niceness of
## getting the old value and setting a new value in one line.
func set_input_mode(new_input_mode):
	var prev_input_mode = game.input_mode
	game.input_mode = new_input_mode
	return prev_input_mode


## Push a scene onto the level root (in a stack-like fashion)
##
## level -> instance of new scene to load onto scene stack
func push_scene(level):
	level_root.add_child(level)


## Swap a scene onto the level root. This will remove the top scene and replace
## it with the new one. If destroy_scene is true, it will free the old scene and
## return null. If destroy_scene is false, it will not free the old scene and
## return a reference to it instead.
##
## level -> instance of resource reference to Level class (or descendent)
## destroy_scene -> bool
func swap_scene(level, destroy_scene):
	var old_level = pop_scene()
	if destroy_scene and old_level:
		old_level.queue_free()

	push_scene(level)
	return old_level if not destroy_scene else null


## Pop the top scene off the level root (in a stack-like fashion)
##
## returns reference to the topmost scene (or null, if the stack is empty)
func pop_scene():
	var child_count = level_root.get_child_count()
	if child_count == 0:
		return null
	
	var scene = level_root.get_child(child_count - 1)
	scene.get_parent().remove_child(scene)
	return scene


## Get a reference to the current scene
func current_scene():
	var child_count = level_root.get_child_count()
	if child_count == 0:
		return null
	
	return level_root.get_child(child_count - 1)
