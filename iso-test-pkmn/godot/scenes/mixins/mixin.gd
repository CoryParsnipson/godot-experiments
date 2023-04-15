extends Node2D

signal enable_changed

export var enable = true setget _on_enable_changed


func _on_ready():
	pass


func _on_process(_delta):
	pass


func _on_physics_process(_delta):
	pass


func _ready():
	if not enable:
		return
	
	yield(self, "ready") # important: wait until all children are initialized before proceeding
	_on_ready()


func _process(_delta):
	if not enable:
		return
	_on_process(_delta)


func _physics_process(_delta):
	if not enable:
		return
	_on_physics_process(_delta)


func _on_enable_changed(new_enable):
	_on_enable_changed_hook(new_enable)
	enable = new_enable
	emit_signal("enable_changed")


func _on_enable_changed_hook(new_enable):
	pass
