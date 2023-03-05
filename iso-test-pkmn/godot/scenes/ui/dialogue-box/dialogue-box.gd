extends NinePatchRect

signal reveal_finished

export (String) onready var advance_dialogue_keybinding = "accept"

onready var reveal_timer = $"reveal-timer"
onready var content = $"content"
onready var content_shadow = $"content-shadow"

var default_reveal_interval = 0.05 # in seconds
var fast_reveal_interval = 0.01 # in seconds

var _unpressed_reveal_interval


func get_text():
	return content.text


func set_text(msg):
	content.text = msg
	content_shadow.text = msg


func set_visible_characters(num_visible):
	content.visible_characters = num_visible
	content_shadow.visible_characters = num_visible


func get_reveal_interval():
	return reveal_timer.wait_time


func set_reveal_interval(reveal_interval):
	if not reveal_interval:
		return
	reveal_timer.wait_time = reveal_interval


func get_color(_type : String = "", _name : String = ""):
	return content.get_color("default_color")
	

func set_color(color):
	if not color:
		return
	content.add_color_override("default_color", color)


func get_shadow_color():
	return content_shadow.get_color("default_color")
	

func set_shadow_color(color):
	if not color:
		return
	content_shadow.add_color_override("default_color", color)


func reveal(reveal_interval = null):
	var num_char = content.text.length()
	if reveal_interval:
		set_reveal_interval(reveal_interval)

	reveal_timer.start()
	for idx in range(num_char + 1):
		set_visible_characters(idx)
		yield(reveal_timer, "timeout")
		
	reveal_timer.stop()
	emit_signal("reveal_finished")


func _ready():
	set_reveal_interval(default_reveal_interval)
	_unpressed_reveal_interval = get_reveal_interval()


func _input(event):
	if event.is_action_pressed(advance_dialogue_keybinding):
		_unpressed_reveal_interval = reveal_timer.wait_time
		set_reveal_interval(fast_reveal_interval)

	if event.is_action_released(advance_dialogue_keybinding):
		set_reveal_interval(_unpressed_reveal_interval)

	# TODO: detect short press and skip to end of reveal?
	pass
