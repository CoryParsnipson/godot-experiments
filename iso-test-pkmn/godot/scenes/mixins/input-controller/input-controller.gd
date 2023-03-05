extends "res://scenes/mixins/mixin.gd"

export (NodePath) onready var character = get_node_or_null(character)
export (NodePath) onready var interaction = get_node_or_null(interaction)


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
		
	if character.movement_state != character.CharacterState.STAND:
		return
		
	if interaction._parent.interactables.empty():
		return
		
	if Input.is_action_just_pressed(interaction.interact_keybinding):
		interaction._parent.interactables[0].interact(character)


func _physics_process(_delta):
	# disable input if we are not in gameplay mode (i.e. in the middle of cutscene or dialogue)
	if game.input_mode != game.InputMode.GAMEPLAY:
		return
	
	handle_character_movement()
	handle_character_interaction()
