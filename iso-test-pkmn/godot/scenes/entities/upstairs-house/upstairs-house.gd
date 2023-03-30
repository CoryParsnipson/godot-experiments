extends Node2D

var _movement_mixin


func on_trigger_entered(body):
	_movement_mixin = body.owner.find_node("movement")
	if _movement_mixin:
		_movement_mixin.connect("pre_move", self, "on_movement")
	
	
func on_trigger_exited(_body):
	if _movement_mixin:
		_movement_mixin.disconnect("pre_move", self, "on_movement")


func on_movement(_movement, _entity):
	_movement.cancel_movement()
	_movement.enable = false
