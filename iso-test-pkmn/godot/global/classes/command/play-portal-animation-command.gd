extends Command
class_name PlayPortalAnimationCommand


func _init(id = "PlayPortalAnimation").(id):
	pass


func execute(locals = {}):
	var door_path = get_context("door", locals)
	var door : Door = game.get_node_or_null(door_path)
	if door == null:
		print("[ERROR] PlayPortalAnimationCommand (%s).execute: Received invalid door entity (%s)" % [id, door])
		return {}

	var target_path = get_context("target", locals)
	var target = game.get_node(target_path)
	if not target:
		print("[ERROR] PlayPortalAnimationCommand (%s).execute: missing character entity to animate (%s)" % \
			[id, target])
		return {}
	
	var door_action = get_context("door-action", locals)
	if door_action == null:
		print("[ERROR] PlayPortalAnimationCommand (%s).exeucte: need door-action. Received (%s)" % [id, door_action])
		return {}
	
	var animations = target.find_node("animations")
	if not animations:
		return {}
	
	# create path string
	var animation_id = Door.animation_id(door.type, door_action, door.facing)
	var path_follower_path = "paths/%s/path-follow" % animation_id
	var remote_transform_path = "%s/remote-transform" % path_follower_path
	
	animations.set_path_members(
		door.get_node(remote_transform_path).get_path(),
		door.get_node(path_follower_path).get_path(),
		target.get_path()
	)	
	animations.play(animation_id)
	yield(animations, "animation_finished")
	
	# snap to tilemap (clear rounding errors that may have been introduced by animation)
	lib_tilemap.snap_to_tilemap(target, lib_tilemap.get_nearest_tilemap(target))
	
	return {}
