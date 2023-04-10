extends Resource
class_name Command

export (String) var id

## normally, multi-commands will wait until each command finishes before executing
## the next one. Setting this will cause the multi-command to move on to the keep
## going even if this command yields. Note that this means the subsequence commands
## in the multi-command will not have access to the return values of this command!
export (bool) var fire_and_forget = false

## use this for information that can be specified before the execution
## and use locals for when information has to be specified at call time
export (Dictionary) var data


## public interface; initialize a new Command. Set a human readable string
## as id for easier debugging.
func _init(_id = "Command"):
	self.id = _id


## public interface; set value of fire and forget
func set_fire_and_forget(_fire_and_forget):
	fire_and_forget = _fire_and_forget
	return self


## public interface; perform some function
##
## locals -> dictionary of parameters to pass (for dependency injection)
##
## return type: Dictionary (to pass information to subsequent commands)
func execute(locals = {}) -> Dictionary:
	print("[WARNING] Command (%s).execute is unimplemented. Locals = %s" % [id, locals])
	return {}


## public interface; undo the execute() method effects, if possible
##
## locals -> dictionary of parameters to pass (for dependency injection)
##
## return type: Dictionary (to pass information to subsequent commands)
func unexecute(locals = {}) -> Dictionary:
	print("[WARNING] Command (%s).unexecute is unimplemented. Locals = %s" % [id, locals])
	return {}


## helper function to get a variable from context; This first checks locals
## and if its not in locals, checks the persistent data member.
func get_context(key, locals, optional = false):
	if not key in locals and not key in data:
		if not optional:
			print("[ERROR] Command (%s).get_context: context '%s' not in locals or data" % [id, key])
		return null
	
	return locals[key] if key in locals else data[key]


## helper function to set data entry; it returns a reference to itself so you
## can do stuff like this:
##
## command_queue.append(
##     Command.new("MyCommand").set_data({
##         "myprop1" : "asdf",
##         "myprop2" : { "subprop1" : 34 },
##     })
## )
##
## dict -> dictionary with data keys and values for use inside execute()
## replace -> if true, will overwrite existing data values with dict; else
##            merge the two dictionaries instead
func set_data(dict, replace = false):
	if replace:
		data = dict
	else:
		data.merge(dict)
	
	return self
