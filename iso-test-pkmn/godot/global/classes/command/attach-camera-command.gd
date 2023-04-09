extends Command
class_name AttachCameraCommand


func _init(id = "AttachCamera").(id):
	pass


func execute(locals = {}):
	var level : Level = get_context("level", locals)
	if not level:
		print("[ERROR] AttachCameraCommand (%s).execute: Received null instead of expected Level" % id)
		return
	
	var target_name = get_context("target", locals)
	var target : Node = level.get_node_or_null(target_name)
	if not target:
		print("[ERROR] AttachCameraCommand (%s).execute: Invalid target to attach camera (%s)" % [id, target_name])
		return
	
	var camera_name = get_context("camera", locals, true)
	var camera = level.get_node_or_null(camera_name if camera_name else "")
	if not camera:
		camera = Camera2D.new()
		
		var instance_name = get_context("camera_name", locals, true)
		if not instance_name:
			instance_name = "player-camera"
		camera.set_name(instance_name)
		
		camera.current = true
		target.add_child(camera)
	
	camera.get_parent().remove_child(camera)
	target.add_child(camera)
	
	var return_key = get_context("return_key", locals, true)
	if not return_key:
		return_key = "camera"
	
	return { return_key : camera }
