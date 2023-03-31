extends "res://scenes/mixins/mixin.gd"

export (NodePath) onready var character = get_node_or_null(character)
export (NodePath) onready var interaction = get_node_or_null(interaction)


## this function exists to detect when the player presses a directional button
## to cause the player to move into an interactable that is trigger on enter.
## For example, when the player walks in front of a sign, it will automatically
## start dialogue. If the player advances through all the dialogue and closes
## the box, the player can retrigger the dialogue by trying to walk into the
## sign and the dialogue will start again. That is what this function is for.
func interact_on_enter_was_retriggered():
	var dirs = {}
	dirs["up"] = Input.is_action_pressed("up")
	dirs["left"] = Input.is_action_pressed("left")
	dirs["right"] = Input.is_action_pressed("right")
	dirs["down"] = Input.is_action_pressed("down")
	
	var mv = lib_movement.get_movement_vector(
		dirs,
		character.movement_strategy,
		character.allow_diagonal
	)
	var mv_dir = lib_movement.vector_to_direction(
		lib_isometric.cartesian_to_isometric(mv)
	)
	var interactable_dir = lib_tilemap.get_direction_of_entity(
		character,
		character.interactables[0]
	)
	return mv_dir == interactable_dir


## the character will move based on player controls
func handle_character_movement():
	if not character:
		return
	
	# if there is a character entity or one that inherits from it, handle movement
	var dirs = {}
	dirs["up"] = Input.is_action_pressed("up")
	dirs["left"] = Input.is_action_pressed("left")
	dirs["right"] = Input.is_action_pressed("right")
	dirs["down"] = Input.is_action_pressed("down")
	
	character.movement_vector = lib_movement.get_movement_vector(dirs, character.movement_strategy, character.allow_diagonal)


## the character interactions will be triggered by player controls
func handle_character_interaction():
	if not interaction:
		return
		
	if character.movement_state != lib_movement.MoveState.STAND:
		return
		
	if character.interactables.empty():
		return

	if Input.is_action_just_pressed(interaction.interact_keybinding):
		character.interactables[0].interact(character)
	elif character.interactables[0].interact_on_enter and interact_on_enter_was_retriggered():
		character.interactables[0].interact(character)


func _on_physics_process(_delta):
	# disable input if we are not in gameplay mode (i.e. in the middle of cutscene or dialogue)
	if game.input_mode != game.InputMode.GAMEPLAY:
		return
	
	handle_character_movement()
	handle_character_interaction()
