extends Node2D


## Needed for interactable mixin
func can_interact(_interactor : Node) -> bool:
	return true
	

## Needed for interactable mixin
func interact(_interactor : Node):
	game.dialogue_manager.exist()
	print("TODO: begin dialog box with text")
