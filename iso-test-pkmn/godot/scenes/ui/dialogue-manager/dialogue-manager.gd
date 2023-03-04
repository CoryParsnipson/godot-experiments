extends Control

export (NodePath) onready var dialogue_box_normal = get_node(dialogue_box_normal)
export (NodePath) onready var dialogue_box_sign = get_node(dialogue_box_sign)


func get_dialogue_box(type):
	match (type):
		game.DialogueBoxType.NORMAL:
			return dialogue_box_normal
		game.DialogueBoxType.SIGN:
			return dialogue_box_sign
		_:
			print("[WARNING] dialogue-manager.get_dialogue_box: invalid box type provided")
			return dialogue_box_normal


func display(data):
	if not data or not data is DialogueData:
		print("[WARNING] dialogue-manager.display: received invalid DialogueData!")
		return
	
	var prev_input_state = game.input_state
	game.input_state = game.InputMode.DIALOGUE
	
	for line in data.lines:
		# TODO: need to yield or something so pressing "accept" will progress through lines
		var dbox = get_dialogue_box(data.dialogue_box_type)
		dbox.text(line)
		dbox.show()
		dbox.reveal()
	
		# TODO: when user presses "accept", the reveal speed should get faster. When they release, the reveal speed
		# should go back to normal. When the user presses "accept" once all the text is revealed, it will
		# start revealing the next line of text or close the dialogue box if there is no more text.
	
	game.input_state = prev_input_state


func _ready():
	# hide all dialogue boxes
	for child in get_children():
		child.hide()
