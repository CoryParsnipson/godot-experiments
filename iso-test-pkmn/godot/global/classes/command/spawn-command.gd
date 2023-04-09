extends Command
class_name SpawnCommand


func _init(id = "Spawn").(id):
	pass


func execute(locals = {}):
	var level : Level = get_context("level", locals)
	if not level:
		print("[ERROR] SpawnCommand (%s).execute: Received null instead of expected Level" % id)
		return
	
	var spawn_id : String = get_context("spawn-id", locals)
	if not spawn_id:
		print("[ERROR] SpawnCommand (%s).execute: Received null instead of spawn_id" % id)
	
	var spawn_props = get_context("spawn-props", locals, true)
	if not spawn_props:
		spawn_props = {}
	
	var return_key = get_context("return-key", locals, true)
	if not return_key:
		return_key = id
	
	var spawns = level.get_spawn_points()
	if spawn_id in spawns:
		var s = spawns[spawn_id].spawn(spawn_props)
		var spawner_return_key = get_context("spawner-return-key", locals, true)
		
		var ret = { return_key : s.get_path() }
		if spawner_return_key:
			ret[spawner_return_key] = spawns[spawn_id]
		
		return ret
	
	return {}
