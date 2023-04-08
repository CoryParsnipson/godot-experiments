tool
extends "res://scenes/_debug/debug.gd"

export (NodePath) var content
export (Color) var key_color = Color.powderblue
export (Color) var value_color = Color.white
export (bool) var start_minimized = true

export (Array, String) var suppress_properties = []
export (Dictionary) var rename_properties = {}

var _properties = {}
var _is_minimized = false setget _resize_menu
var _min_btn = null


func _decode_hint_string(hint):
	var decoded = {}
	var enum_values = hint.split(",", false)
	for val in enum_values:
		var kv = val.split(":", false)
		if kv.size() != 2:
			continue
		decoded[int(kv[1])] = kv[0]
	
	return decoded


func _update_entity_info():
	var properties = entity.get_property_list()
	
	for property in properties:
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var property_value = entity.get(property.name)
			if property.hint_string:
				var enum_string = _decode_hint_string(property.hint_string)
				if not enum_string.empty():
					property_value = enum_string[property_value]
				
			if property.name in suppress_properties:
				continue
			
			if property.name in rename_properties and rename_properties[property.name] is String:
				property.name = rename_properties[property.name]
			
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


func _clear_menu():
	for child in content.get_children():
		if not (child is HBoxContainer):
			continue
		
		child.queue_free()


func _resize_menu(is_minimized):
	_is_minimized = is_minimized
	if _is_minimized:
		_clear_menu()
		_min_btn.text = "[v]"
	else:
		_update_entity_info()
		_draw_entity_info()
		_min_btn.text = "[-]"
	update()


func _on_minimize_toggled(button_pressed):
	_resize_menu(button_pressed)


func _ready():
	if Engine.editor_hint:
		return
	
	content = get_node_or_null(content)
	if not content:
		print("[WARNING] entity-info.ready: content nodepath is unset (%s)" % content)
	
	_min_btn = content.get_node_or_null("button-minimize")
	if _min_btn:
		_min_btn.set_pressed(start_minimized)
	

func _process(_delta):
	if Engine.editor_hint:
		return
	
	if not _is_minimized:
		_update_entity_info()
		_draw_entity_info()
