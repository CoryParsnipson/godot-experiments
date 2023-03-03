extends Control

enum DialogueBoxType { NORMAL, SIGN }

export (NodePath) onready var dialogue_box_normal = get_node(dialogue_box_normal)
export (NodePath) onready var dialogue_box_sign = get_node(dialogue_box_sign)


func exist():
	print("DIALOGUE MANAGER IS HERE")
