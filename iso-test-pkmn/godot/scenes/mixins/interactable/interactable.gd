extends "res://scenes/mixins/mixin.gd"

export (NodePath) onready var interactable_parent = get_node(interactable_parent)


func can_interact(interactor : Node) -> bool:
	if interactable_parent and interactable_parent.has_method("can_interact"):
		return interactable_parent.can_interact(interactor)
	
	print("[WARNING] (interactable.can_interact): interactable does not have can_interact() defined.")
	return false


func interact(interactor : Node):
	if interactable_parent and interactable_parent.has_method("interact"):
		return interactable_parent.interact(interactor)
	
	print("[WARNING] (interactable.interact): interactable does not have interact() defined.")\
