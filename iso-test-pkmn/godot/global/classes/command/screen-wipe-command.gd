extends Command
class_name ScreenWipeCommand


func _init(id = "ScreenWipe").(id):
	pass


func execute(locals = {}):
	var screen_wipe = get_context("screen-wipe", locals)
	if not screen_wipe:
		print(
			"[ERROR] ScreenWipeCommand (%s).execute: received invalid screen-wipe entity (%s)." % \
			[id, screen_wipe])
		return {}
	
	var type = get_context("type", locals)
	screen_wipe.wipe(type)
	
	var pre_delay = get_context("pre-wipe-delay", locals, true)
	if pre_delay:
		screen_wipe.pause()
		screen_wipe.seek(0.01, true)
		yield(game.get_tree().create_timer(pre_delay), "timeout")
		screen_wipe.resume()
	
	yield(screen_wipe, "screen_wipe_done")
	
	var post_delay = get_context("post-wipe-delay", locals, true)
	if post_delay:
		yield(game.get_tree().create_timer(post_delay), "timeout")
	
	return {}
