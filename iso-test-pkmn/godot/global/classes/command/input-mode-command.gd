extends Command
class_name InputModeCommand


func _init(id = "InputMode").(id):
	pass


func execute(locals = {}):
	var input_mode = get_context("input-mode", locals)
	if input_mode == null:
		print("[ERROR] InputModeCommand (%s).execute: invalid input-mode provided (%s)" % [id, input_mode])
		return {}
	
	var return_key = get_context("return-key", locals, true)
	if not return_key:
		return_key = id
	
	return { return_key : game.set_input_mode(input_mode) }
