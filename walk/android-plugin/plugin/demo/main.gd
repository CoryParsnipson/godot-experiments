extends Control

var _plugin_name = "GodotStepsCounterPlugin"
var _permissions = [
	"android.permission.ACTIVITY_RECOGNITION",
]
var _android_plugin

func _ready():
	if Engine.has_singleton(_plugin_name):
		_android_plugin = Engine.get_singleton(_plugin_name)

	if require_android_plugin():
		print("%s successfully loaded!" % _plugin_name)
		_android_plugin.enableToast()
		_android_plugin.healthCheck()


func require_android_plugin():
	if not _android_plugin:
		printerr("Couldn't find plugin " + _plugin_name)
		return false
	return true


func _on_Button_pressed():
	if not require_android_plugin():
		return

	if not _android_plugin.hasPermission(_permissions[0]):
		_android_plugin.shouldShowRequestPermissionRationale(_permissions[0])
		OS.request_permission(_permissions[0])

	print("button pressed!")
