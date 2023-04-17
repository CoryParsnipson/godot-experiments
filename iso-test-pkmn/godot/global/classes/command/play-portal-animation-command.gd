extends Command
class_name PlayPortalAnimationCommand


func _init(id = "PlayPortalAnimation").(id):
	pass


func execute(locals = {}):
	var level : Level = get_context("level", locals)
	if not level:
		print("[ERROR] PlayPortalAnimationCommand (%s).execute: Received null instead of expected Level" % id)
		return
	
	var last_spawn_point_path = get_context("last-spawn-point", locals)
	var last_spawn_point = level.get_node(last_spawn_point_path)
	if not last_spawn_point:
		print("[ERROR] PlayPortalAnimationCommand (%s).execute: received invalid last_spawn_point (%s)" % \
			[id, last_spawn_point])
		return {}
	
	var target_path = get_context("target", locals)
	var target = level.get_node(target_path)
	if not target:
		print("[ERROR] PlayPortalAnimationCommand (%s).execute: missing character entity to animate (%s)" % \
			[id, target])
		return {}
	
	var facing = get_context("facing", locals)
	if not facing:
		print("[ERROR] PlayPortalAnimationCommand (%s).execute: need direction value for animation received (%s)" % \
			[id, facing])
		return {}
	
	var portal_action = get_context("portal-action", locals, true)
	if not portal_action:
		portal_action = "exit"
	
	var animations = target.find_node("animations")
	if not animations:
		return {}
		
	var movement = target.find_node("movement")
	if not movement:
		return {}
	
	# create path string
	var path_selector = "%s-%s-%s" % [ \
		Door.DoorType.keys()[last_spawn_point.type].to_lower(), \
		portal_action, \
		lib_movement.direction_suffix_str(facing)
	]
	var path_follower_path = "paths/%s/path-follow" % path_selector
	var remote_transform_path = "%s/remote-transform" % path_follower_path
	
	animations.set_path_members(
		last_spawn_point.get_node(remote_transform_path).get_path(),
		last_spawn_point.get_node(path_follower_path).get_path(),
		target.get_path()
	)	
	animations.play(path_selector)
	yield(animations, "animation_finished")
	
	# snap to tilemap (clear rounding errors that may have been introduced by animation)
	lib_tilemap.snap_to_tilemap(target, lib_tilemap.get_nearest_tilemap(target))
	
	return {}
