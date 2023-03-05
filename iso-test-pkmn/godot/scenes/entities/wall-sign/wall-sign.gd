extends Node2D

export (Resource) var interact_data

## Needed for interactable mixin
func can_interact(_interactor : Node) -> bool:
	return true
	

## Needed for interactable mixin
func interact(_interactor : Node):
	game.dialogue.play(interact_data)
