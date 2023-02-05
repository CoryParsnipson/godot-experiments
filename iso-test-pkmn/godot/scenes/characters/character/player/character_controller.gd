extends Node2D

export (NodePath) onready var _state = get_node(_state)


func _physics_process(delta):
	# pass movement script the input from keyboard
	_state.movement_vector = lib_movement.get_input(_state.movement_strategy)
