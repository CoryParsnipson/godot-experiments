extends Node2D

func on_trigger_entered(body):
	print("body '%s' has entered trigger area of %s" % [body.name, name])
	
	
func on_trigger_exited(body):
	print("body '%s' has exited trigger area of %s" % [body.name, name])
