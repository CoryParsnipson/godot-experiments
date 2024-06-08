extends Control

enum Permission { UNKNOWN, GRANTED, NOT_GRANTED }

var _plugin_name = "GodotStepsCounterPlugin"
var _permissions = {
	"android.permission.ACTIVITY_RECOGNITION" : Permission.UNKNOWN,
}
var _android_plugin

@onready var btn_start_fg = $content/margin_btn_fg/btn_start_fg
@onready var btn_start_bg = $content/margin_btn_bg/btn_start_bg

@onready var btn_start_fg_text = $content/margin_btn_fg/btn_start_fg.text
@onready var btn_start_bg_text = $content/margin_btn_bg/btn_start_bg.text

@onready var step_counter_val_label = $content/steps_counter/margin/content/steps_display/val
@onready var step_counter_accuracy_label = $content/steps_counter/margin/content/accuracy_display/val

@onready var step_counter_service_type = $content/service_type/margin/service_type_display/val

func _ready():
	if Engine.has_singleton(_plugin_name):
		_android_plugin = Engine.get_singleton(_plugin_name)

	if not require_android_plugin():
		return

	# hook up signals
	get_tree().on_request_permissions_result.connect(on_request_permissions_result)
	_android_plugin.on_step_counter_updated.connect(on_step_counter_update)
	_android_plugin.on_step_counter_accuracy_changed.connect(on_step_counter_accuracy_changed)
	_android_plugin.on_service_type_changed.connect(on_service_type_changed)

	print("%s successfully loaded!" % _plugin_name)
	_android_plugin.enableToast()
	_android_plugin.healthCheck()

	# get updated info immediately if we start and discover that the steps
	# counter service is still up and running
	if _android_plugin.isStepsCounterServiceRunning():
		print("Steps Counter Service is already running. Requesting steps counter info...")
		_android_plugin.updateStepsCounterInfo()

		btn_start_fg.button_pressed = true
		set_start_fg_button_text()


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


func reset_fg_button_text():
	btn_start_fg.text = btn_start_fg_text


func reset_bg_button_text():
	btn_start_bg.text = btn_start_bg_text


func set_start_fg_button_text():
	btn_start_fg.text = "Step Counter (fg) active..."


func set_start_bg_button_text():
	btn_start_bg.text = "Step Counter (bg) active..."


func set_step_counter_display(val):
	step_counter_val_label.text = str(val)


func set_step_counter_accuracy_display(accuracy):
	step_counter_accuracy_label.text = str(accuracy)


func reset_step_counter_display(val = "UNDEFINED"):
	set_step_counter_display(val)


func on_step_counter_update(steps_since_last_reboot):
	set_step_counter_display(steps_since_last_reboot)


func on_step_counter_accuracy_changed(accuracy):
	set_step_counter_accuracy_display(accuracy)


func on_service_type_changed(service_type: String):
	step_counter_service_type.text = service_type


func _on_start_fg_button_toggled(toggled_on: bool):
	if not require_android_plugin():
		return

	var granted = await request_permissions()
	if not granted:
		print("Could not get all permissions needed...")
		return

	print("foreground button pressed: " + ("PRESSED" if toggled_on else "NOT PRESSED"))
	if toggled_on:
		_android_plugin.startStepsCounterForegroundService()

		call_deferred("reset_step_counter_display", 0)
		call_deferred("set_start_fg_button_text")
	else:
		_android_plugin.stopStepsCounterService()
		call_deferred("reset_fg_button_text")


func _on_start_bg_button_toggled(toggled_on: bool):
	if not require_android_plugin():
		return

	var granted = await request_permissions()
	if not granted:
		print("Could not get all permissions needed...")
		return

	print("background button pressed: " + ("PRESSED" if toggled_on else "NOT PRESSED"))

	if toggled_on:
		_android_plugin.startStepsCounterBackgroundService()

		call_deferred("reset_step_counter_display", 0)
		call_deferred("set_start_bg_button_text")
	else:
		_android_plugin.stopStepsCounterService()
		call_deferred("reset_bg_button_text")
