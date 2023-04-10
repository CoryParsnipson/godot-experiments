extends AnimationPlayer

export var _remote_transform_target : NodePath
export var _path_follower_target : NodePath
export var _entity_target : NodePath

export var _path_follower_offset = 0.0 setget set_path_follower_offset


func set_path_follower_offset(offset):
	var path_follower = get_node_or_null(_path_follower_target)
	if not path_follower:
		return
	
	path_follower.unit_offset = offset


func set_remote_transform_path(remote_transform_path = _remote_transform_target, target = _entity_target):
	var remote_transform : RemoteTransform2D = get_node(remote_transform_path)
	remote_transform.remote_path = target
	
	
func unset_remote_transform_path(remote_transform_path = _remote_transform_target):
	var remote_transform : RemoteTransform2D = get_node(remote_transform_path)
	remote_transform.remote_path = ""


func set_path_members(remote_transform_path, path_follower_target, entity_target):
	_remote_transform_target = remote_transform_path
	_path_follower_target = path_follower_target
	_entity_target = entity_target


func unset_path_members():
	_remote_transform_target = ""
	_path_follower_target = ""
	_entity_target = ""
