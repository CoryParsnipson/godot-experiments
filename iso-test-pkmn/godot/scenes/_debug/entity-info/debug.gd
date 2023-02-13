extends "res://scenes/_debug/debug.gd"

export (NodePath) onready var content = get_node(content)
export (Color) var key_color = Color.powderblue
export (Color) var value_color = Color.white

var _properties = {}


func _decode_hint_string(hint):
	var decoded = {}
	var enum_values = hint.split(",", false)
	for val in enum_values:
		var kv = val.split(":", false)
		decoded[int(kv[1])] = kv[0]
	
	return decoded


func _update_entity_info():
	var properties = entity.get_property_list()
	
	for property in properties:
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var property_value = entity.get(property.name)
			if property.hint_string:
				var enum_string = _decode_hint_string(property.hint_string)
				property_value = enum_string[property_value]
				
			_properties[property.name] = property_value


func _draw_entity_info():
	for property in _properties.keys():
		var property_entry = content.get_node_or_null(property)
		if not property_entry:
			var entry = content.get_parent().get_node_or_null("default-text").duplicate()
			if not entry:
				entry = Label.new()
			
			entry.name = "key"
			entry.text = property + ":"
			entry.set("custom_colors/font_color", key_color)
			entry.show()
			
			var entry_container = HBoxContainer.new()
			entry_container.name = property
			entry_container.add_child(entry)
			
			entry = entry.duplicate()
			entry.name = "value"
			entry.text = str(_properties[property])
			entry.set("custom_colors/font_color", value_color)
			entry_container.add_child(entry)
			
			content.add_child(entry_container)
		else:
			var entry = property_entry.get_node_or_null("value")
			entry.text = str(_properties[property])


func _process(_delta):
	_update_entity_info()
	_draw_entity_info()
