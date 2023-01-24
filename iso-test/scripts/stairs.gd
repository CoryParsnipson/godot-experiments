extends Area2D

func _on_body_entered(body):
	if (!body.is_in_group("movable")):
		return
		
	body.set("onStairs", true)

func _on_body_exited(body):
	if (!body.is_in_group("movable")):
		return
	
	body.set("onStairs", false)
