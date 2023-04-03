extends ColorRect
class_name ScreenWipe

enum Type { FADE_TO_BLACK, FADE_TO_NORMAL }

signal screen_wipe_done(type)


func screen_wipe_to_string(type):
	match type:
		Type.FADE_TO_BLACK:
			return "fade-to-black"
		Type.FADE_TO_NORMAL:
			return "fade-to-normal"
		_:
			print("[WARNING] screen_wipe_to_string: received invalid screen wipe type '%s'" % type)
			return ""


func string_to_screen_wipe(type_string):
	var keys = Type.keys()
	var idx = keys.find(type_string)
	
	if idx == -1:
		print("[WARNING] string_to_screen_wipe: received invalid screen wipe string '%s'" % type_string)
		return ""
	
	return keys[idx]


func wipe(type):
	show()
	$animations.play(screen_wipe_to_string(type))


func _on_animation_finished(anim_name):
	emit_signal("screen_wipe_done", anim_name)
