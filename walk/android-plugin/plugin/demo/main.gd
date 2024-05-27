extends Control

enum Permission { UNKNOWN, GRANTED, NOT_GRANTED }

var _plugin_name = "GodotStepsCounterPlugin"
var _permissions = {
	"android.permission.ACTIVITY_RECOGNITION" : Permission.UNKNOWN,
}
var _android_plugin


func _ready():
	if Engine.has_singleton(_plugin_name):
		_android_plugin = Engine.get_singleton(_plugin_name)

	if not require_android_plugin():
		return

	# hook up signals
	get_tree().on_request_permissions_result.connect(on_request_permissions_result)
	_android_plugin.on_step_counter_updated.connect(on_step_counter_update)

	print("%s successfully loaded!" % _plugin_name)
	_android_plugin.enableToast()
	_android_plugin.healthCheck()


func require_android_plugin():
	if not _android_plugin:
		printerr("Couldn't find plugin " + _plugin_name)
		return false
	return true


func on_request_permissions_result(permission: String, granted: bool):
	if permission in _permissions:
		_permissions[permission] = Permission.GRANTED if granted else Permission.NOT_GRANTED
	else:
		print("[WARNING] received permission result for unknown permission: %s" % permission)


func request_permissions() -> bool:
	var has_all_perms = true
	for perm in _permissions:
		if (_permissions[perm] == Permission.GRANTED):
			continue

		if not _android_plugin.hasPermission(perm):
			# should use the result of this function to throw up a dialog box
			_android_plugin.shouldShowRequestPermissionRationale(perm)
			OS.request_permission(perm)

			await get_tree().on_request_permissions_result
			print("Received permission result for %s: %s" % [perm, Permission.keys()[_permissions[perm]]])
			has_all_perms = has_all_perms and has_permission(perm)
	return has_all_perms


func has_permission(perm : String) -> bool:
	return _permissions[perm] == Permission.GRANTED


func has_all_permissions() -> bool:
	for perm in _permissions:
		if _permissions[perm] != Permission.GRANTED:
			return false
	return true


func disable_register_listener_button():
	$VBoxContainer/btn_margin/btn_register_listener.text = "Step Counter active..."
	$VBoxContainer/btn_margin/btn_register_listener.disabled = true


func set_step_counter_display(val):
	$VBoxContainer/PanelContainer/MarginContainer/step_counter_container/steps_display/steps_val.text = str(val)


func reset_step_counter_display(val = "UNDEFINED"):
	set_step_counter_display(val)


func on_step_counter_update(steps_since_last_reboot):
	set_step_counter_display(steps_since_last_reboot)


func _on_Button_pressed():
	if not require_android_plugin():
		return

	var granted = await request_permissions()
	if not granted:
		print("Could not get all permissions needed...")
		return

	print("checking steps...")
	_android_plugin.checkSteps()

	print("button pressed!")

	# no idea why we need to use call_deferred here; otherwise
	# the get node call will return null
	call_deferred("reset_step_counter_display", 0)
	call_deferred("disable_register_listener_button")
