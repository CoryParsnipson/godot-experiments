extends "res://scenes/mixins/mixin.gd"

export (NodePath) onready var _state = get_node(_state)
export (NodePath) onready var _parent = get_node(_parent)


func _on_interactable_entered(area):
	if not _state:
		print("[WARNING] (interaction._on_interactable_entered): entity _state node not provided")
		return
	
	if area.owner.can_interact(_parent):
		_state.interactables.push_back(area.owner.interactable_parent)


func _on_interactable_exited(area):
	if not _state:
		print("[WARNING] (interaction._on_interactable_entered): entity _state node not provided")
		return
	
	_state.interactables.erase(area.owner.interactable_parent)


func _physics_process(_delta):
	if _state.movement_state == _state.CharacterState.STAND and Input.is_action_just_released("interact"):
		if _state.interactables.empty():
			return
		
		_state.interactables[0].interact(_state)
