extends Node2D

export (NodePath) onready var map = get_node(map)
export (NodePath) onready var debug_zlevel = get_node(debug_zlevel)
export (int) var destZ = 1
export (int) var collisionLayer = 1
export (int) var areaLayer = 2

var zlevelRegex = RegEx.new()

func _ready():
	zlevelRegex.compile("^z\\-?[0-9]+$")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func str2Zlevel(z):
	return "z%d" % z
	

func getZLevel(node):
	var zlevel = node.get_parent().get_parent()
	if (!zlevel or !zlevelRegex.search(zlevel.name)):
		push_warning("Node %s is not attached to a map zlevel" % node.name)
		return 0
		
	return int(zlevel.name.substr(1, -1))


func setCollisionEnable(zlevel, enable):
	var collision = map.get_node_or_null(str2Zlevel(zlevel) + "/collision")
	if (collision):
		collision.set_collision_mask_bit(collisionLayer - 1, enable)
		collision.set_collision_layer_bit(collisionLayer - 1, enable)


func setTriggerEnable(zlevel, enable):
	var triggers = map.get_node_or_null(str2Zlevel(zlevel) + "/triggers")
	if (triggers):
		for area in triggers.get_children():
			area.set_collision_mask_bit(areaLayer - 1, enable)
			area.set_collision_layer_bit(areaLayer - 1, enable)


func moveToNewZLevel(node):
	var currZ = getZLevel(node)
	if (currZ == destZ):
		push_warning("moveToNewZLevel: destZ level is same as currZ level: %d" % currZ)
		return;
	
	print ("body-entered: moving from zlevel %d to zlevel %d" % [currZ, destZ])
	
	var destMap = map.get_node(str2Zlevel(destZ))
	var destTileMap = destMap.get_node("main")
	
	destMap.show()
	
	# move object to new zlevel
	node.get_parent().remove_child(node)
	destTileMap.call_deferred("add_child", node)
	node.call_deferred("set_owner", destTileMap)
	
	# enable stuff on new zlevel
	setTriggerEnable(destZ, true)
	setCollisionEnable(destZ, true)
	
	# disable old zlevel stuff
	setTriggerEnable(currZ, false)
	setCollisionEnable(currZ, false)
	
	var srcLevel = map.get_node(str2Zlevel(currZ))
	var hideOnLeave = srcLevel.get("hideOnLeave")
	if hideOnLeave:
		srcLevel.hide()
	
	# print to debug panel
	debug_zlevel.text = str(destZ)


func _on_body_entered(body):
	if (body.is_in_group("movable")):
		print("body exited")


func _on_body_exited(body):
	if (body.is_in_group("movable")):
		moveToNewZLevel(body)
