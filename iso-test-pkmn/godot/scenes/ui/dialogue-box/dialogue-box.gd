extends NinePatchRect

onready var reveal_timer = $"reveal-timer"
onready var content = $"content"
onready var content_shadow = $"content-shadow"

var default_reveal_interval = 0.05 # in seconds


func text(msg):
	content.text = msg
	content_shadow.text = msg
	
	
func visible_characters(num_visible):
	content.visible_characters = num_visible
	content_shadow.visible_characters = num_visible


func get_reveal_interval():
	return reveal_timer.wait_time


func set_reveal_interval(reveal_interval):
	reveal_timer.wait_time = reveal_interval

	
func reveal(reveal_interval = default_reveal_interval):
	var num_char = content.text.length()
	reveal_timer.wait_time = reveal_interval

	reveal_timer.start()
	for idx in range(num_char + 1):
		visible_characters(idx)
		yield(reveal_timer, "timeout")
		

func _ready():
	reveal_timer.wait_time = default_reveal_interval
