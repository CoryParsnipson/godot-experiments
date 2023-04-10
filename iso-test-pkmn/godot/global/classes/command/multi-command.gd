extends Command
class_name MultiCommand

export (Array, Resource) var commands


func _init(id = "MultiCommand").(id):
	return self


## public interface; use this to add commands to this multicommand
func append(command : Command):
	commands.append(command)
	return self


## public interface; use this to check if there are subcommands
func empty() -> bool:
	return commands.empty()


func execute(locals = {}) -> Dictionary:
	var return_values = {}
	for command in commands:
		if not command is Command:
			print("[WARNING] MultiCommand (%s).execute: expecting command, received %s" % [id, command])
			continue
		
		var input = locals.duplicate()
		input.merge(return_values)
		
		var ret = command.execute(input)
		if command.fire_and_forget:
			continue
		
		if ret is GDScriptFunctionState:
			ret = yield(ret, "completed")
		return_values.merge(ret, true)
	
	return return_values


func unexecute(locals = {}) -> Dictionary:
	var return_values = {}
	for command in commands:
		if not command is Command:
			print("[WARNING] MultiCommand (%s).unexecute: expecting command, received %s" % [id, command])
			continue
		
		var input = locals.duplicate()
		input.merge(return_values)
		
		var ret = command.unexecute(input)
		if ret is GDScriptFunctionState:
			ret = yield(ret, "completed")
		return_values.merge(ret, true)
	
	return return_values
