extends Resource
class_name DialogueData

export (int) var version = 1

export (Color) var color = null
export (Color) var shadow_color = null
export (float) var reveal_interval = null
export (float) var fast_reveal_interval = null
export (game.DialogueBoxType) var dialogue_box_type = null
export (Array, String) var lines = []
export (bool) var allow_skip = true
export (bool) var disable_game_input = true


func to_json():
	var data = {}	
	for p in get_script().get_script_property_list():
		data[p.name] = get(p.name)
	
	# put this in here for human readability
	var script_name = get_script().get_path().split("/")
	if script_name.size() >= 1:
		script_name = script_name[script_name.size() - 1]
	else:
		script_name = get_script().get_path()
	
	data["class_name"] = script_name.replace(".gd", "")

	return JSON.print(data, "", true)


func from_json(json_string):
	var json_result = JSON.parse(json_string)
	if json_result.error != OK:
		print("[WARNING] DialogueData.from_json: json parse failed!")
		return
	
	for p in json_result.result:
		if not p in self:
			continue
		set(p, json_result.result[p])


func generate_auto_chunks(_dialogue_box):
	# TODO: implement feature where the dialogue manager can automatically split up lines that
	# are too long into multiple lines.
	#
	# NOTE: in the original game, this has a special animation where the lines scroll up. See the
	# TV on the first floor of the player's house.
	pass
