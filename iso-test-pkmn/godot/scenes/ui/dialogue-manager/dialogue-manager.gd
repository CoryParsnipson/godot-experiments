extends Control

signal advance_dialogue

export (String) onready var advance_dialogue_keybinding = "accept"

export (NodePath) onready var dialogue_box_normal = get_node(dialogue_box_normal)
export (NodePath) onready var dialogue_box_sign = get_node(dialogue_box_sign)

onready var _prev_input_mode = game.input_mode
onready var _orig_dialogue_box_settings = DialogueData.new()


func play(data):
	if not data or not data is DialogueData:
		print("[WARNING] dialogue-manager.play: received invalid DialogueData!")
		return

	var dbox = _get_dialogue_box(data.dialogue_box_type)

	_set_input_mode()
	_setup_dialogue_box(dbox, data)

	for line in data.lines:
		dbox.set_text(line)
		
		dbox.reveal()
		yield(dbox, "reveal_finished")
		yield(self, "advance_dialogue")
	
	_teardown_dialogue_box(dbox)
	_unset_input_mode()


func _set_input_mode():
	_prev_input_mode = game.input_mode
	game.input_mode = game.InputMode.DIALOGUE


func _unset_input_mode():
	game.input_mode = _prev_input_mode


func _setup_dialogue_box(dbox, data):
	# capture original settings
	_orig_dialogue_box_settings.color = dbox.get_color()
	_orig_dialogue_box_settings.shadow_color = dbox.get_shadow_color()
	_orig_dialogue_box_settings.reveal_interval = dbox.get_reveal_interval()
	_orig_dialogue_box_settings.fast_reveal_interval = dbox.get_fast_reveal_interval()
	
	# override settings based on DialogueData
	dbox.set_text("")
	dbox.set_color(data.color)
	dbox.set_shadow_color(data.shadow_color)
	dbox.set_reveal_interval(data.reveal_interval)
	dbox.set_fast_reveal_interval(data.fast_reveal_interval)
	
	dbox.show()


func _teardown_dialogue_box(dbox):
	dbox.set_text("")
	dbox.set_color(_orig_dialogue_box_settings.color)
	dbox.set_shadow_color(_orig_dialogue_box_settings.shadow_color)
	dbox.set_reveal_interval(_orig_dialogue_box_settings.reveal_interval)
	dbox.set_fast_reveal_interval(_orig_dialogue_box_settings.fast_reveal_interval)
	
	dbox.hide()


func _get_dialogue_box(type):
	match (type):
		game.DialogueBoxType.NORMAL:
			return dialogue_box_normal
		game.DialogueBoxType.SIGN:
			return dialogue_box_sign
		_:
			print("[WARNING] dialogue-manager.get_dialogue_box: invalid box type provided")
			return dialogue_box_normal


func _ready():
	# hide all dialogue boxes
	for child in $"dialogue-boxes".get_children():
		child.hide()


func _input(event):
	# check if we are in the middle of dialogue and player wants to continue to the next line
	if event.is_action_pressed(advance_dialogue_keybinding):
		# IMPORTANT: defer this call so the signal get emitted on the next frame. It is important
		# because if we don't do this, the input controller will detect the "accept" input as
		# released and the same button press to close the current dialogue will trigger the dialogue
		# to start again.
		call_deferred("emit_signal", "advance_dialogue")
		get_tree().set_input_as_handled() # block all other handlers from using this event
