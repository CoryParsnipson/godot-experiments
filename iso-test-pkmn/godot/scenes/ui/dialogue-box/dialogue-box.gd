extends NinePatchRect

enum WakeupReason { SKIP, REVEAL_TIMEOUT }

signal reveal_skip
signal reveal_finished
signal _wakeup(reason)

## this is set by dialogue-manager when it is currently using this dialogue box (do not touch)
export (bool) onready var is_active = false
export (bool) onready var allow_skip = true
export (String) onready var advance_dialogue_keybinding = "accept"
export (int) onready var shortpress_threshold = 200 # in milliseconds

onready var reveal_timer = $"reveal-timer"
onready var content = $"content"
onready var content_shadow = $"content-shadow"

var default_reveal_interval = 0.05 # in seconds
var fast_reveal_interval = 0.01 # in seconds

var _unpressed_reveal_interval
var _reveal_in_progress = false
var _button_press_start


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


func get_fast_reveal_interval():
	return fast_reveal_interval


func set_fast_reveal_interval(interval):
	if not interval:
		return
	fast_reveal_interval = interval


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


func _setup_reveal(reveal_interval):
	if reveal_interval:
		set_reveal_interval(reveal_interval)
	
	_reveal_in_progress = true
	_button_press_start = null
	_wait_on_skip_signal()


func _teardown_reveal():
	set_visible_characters(content.text.length() + 1)
	
	_reveal_in_progress = false
	_button_press_start = null
	emit_signal("reveal_finished")


func reveal(reveal_interval = null):
	_setup_reveal(reveal_interval)
	
	for idx in range(content.text.length() + 1):
		set_visible_characters(idx)
		
		_wait_on_reveal_timer()
		if yield(self, "_wakeup") == WakeupReason.SKIP:
			_teardown_reveal()
			return
	
	_teardown_reveal()


func _wait_on_reveal_timer():
	reveal_timer.start()
	yield(reveal_timer, "timeout")
	emit_signal("_wakeup", WakeupReason.REVEAL_TIMEOUT)


func _wait_on_skip_signal():
	yield(self, "reveal_skip")
	emit_signal("_wakeup", WakeupReason.SKIP)


func _is_shortpress(start_time):
	if not start_time:
		return false
	
	return OS.get_ticks_msec() - start_time <= shortpress_threshold


func _ready():
	set_reveal_interval(default_reveal_interval)
	_unpressed_reveal_interval = get_reveal_interval()


func _input(event):
	if is_active and _reveal_in_progress and event.is_action_pressed(advance_dialogue_keybinding):
		_unpressed_reveal_interval = get_reveal_interval()
		set_reveal_interval(get_fast_reveal_interval())
		_button_press_start = OS.get_ticks_msec()

	if is_active and _reveal_in_progress and event.is_action_released(advance_dialogue_keybinding):
		set_reveal_interval(_unpressed_reveal_interval)
		
		if allow_skip and _is_shortpress(_button_press_start):
			emit_signal("reveal_skip")
