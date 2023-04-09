extends Command
class_name FuncrefCommand


func _init(id = "FuncrefCommand").(id):
	pass


func execute(locals = {}):
	var fr = get_context("funcref", locals)
	if not fr:
		print("[ERROR] FuncrefCommand (%s).execute: received invalid funcref (%s)" % fr)
		return {}
	
	var props = get_context("props", locals, true)
	if not props:
		props = []
	
	var return_key = get_context("return_key", locals, true)
	if not return_key:
		return_key = id
	
	return { return_key : fr.callv("call_func", props) }
