extends Area2D

export (bool) var show_uninitialized_warning = false
export (NodePath) var _action

export (String) var enter_callback = "on_trigger_entered"
export (String) var exit_callback = "on_trigger_exited"


func _ready():
	_action = get_node_or_null(_action)


func _on_trigger_body_entered(body):
	var action = _action if _action else owner
	if not action.has_method("on_trigger_entered"):
		if show_uninitialized_warning:
			print("[WARNING] trigger.entered on (%s): action does not have on_trigger_entered defined." % owner.name)
		return
		
	action.call(enter_callback, body)


func _on_trigger_body_exited(body):
	var action = _action if _action else owner
	if not action.has_method("on_trigger_exited"):
		if show_uninitialized_warning:
			print("[WARNING] trigger.exited on (%s): action does not have on_trigger_exited defined." % owner.name)
		return
		
	action.call(exit_callback, body)
