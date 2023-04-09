extends AnimationPlayer

export var _remote_transform_target : NodePath
export var _path_follower_target : NodePath
export var _path_follow_target : NodePath

export var _path_follower_offset = 0.0 setget set_path_follower_offset


func set_path_follower_offset(offset):
	var path_follower = get_node(_path_follower_target)
	path_follower.unit_offset = offset


func set_remote_transform_path(remote_transform_path = _remote_transform_target, target = _path_follow_target):
	var remote_transform : RemoteTransform2D = get_node(remote_transform_path)
	remote_transform.remote_path = target
	
	
func unset_remote_transform_path(remote_transform_path = _remote_transform_target):
	var remote_transform : RemoteTransform2D = get_node(remote_transform_path)
	remote_transform.remote_path = ""
