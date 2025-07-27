@tool
extends RefCounted

func export_project_structure() -> bool:
	var output = {
		"project_name": ProjectSettings.get_setting("application/config/name", "Unknown"),
		"generated_timestamp": Time.get_datetime_string_from_system(),
		"scenes": [],
		"scripts": [],
		"autoloads": {},
		"project_settings": get_relevant_project_settings()
	}
	
	# Get all scene files
	var scene_files = find_files_recursive("res://", "tscn")
	var total_files = scene_files.size()
	
	print("AI Context Generator: Found %d scenes to process..." % total_files)
	
	# Process each scene
	for i in range(scene_files.size()):
		var scene_path = scene_files[i]
		
		print("AI Context Generator: Processing scene %d/%d: %s" % [i+1, total_files, scene_path.get_file()])
		
		var scene_data = parse_scene_structure(scene_path)
		if scene_data:
			output.scenes.append(scene_data)
	
	# Get all script files
	var script_files = find_files_recursive("res://", "gd")
	script_files.append_array(find_files_recursive("res://", "cs"))
	
	print("AI Context Generator: Processing %d scripts..." % script_files.size())
	
	# Process each script
	for i in range(script_files.size()):
		var script_path = script_files[i]
		
		var script_data = extract_script_info(script_path)
		if script_data:
			output.scripts.append(script_data)
	
	# Get autoloads
	output.autoloads = get_autoloads()
	
	# Save to file
	var json_string = JSON.stringify(output, "\t")
	var file = FileAccess.open("res://ai_context_export.json", FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		file.close()
		
		# Copy to clipboard
		DisplayServer.clipboard_set(json_string)
		
		print("AI Context Generator: Successfully generated ai_context_export.json")
		print("AI Context Generator: JSON data copied to clipboard!")
		return true
	else:
		print("AI Context Generator: Failed to write export file")
		return false

func find_files_recursive(path: String, extension: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + "/" + file_name
			
			if dir.current_is_dir() and not file_name.begins_with("."):
				files.append_array(find_files_recursive(full_path, extension))
			elif file_name.get_extension() == extension:
				files.append(full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return files

func parse_scene_structure(scene_path: String) -> Dictionary:
	var scene = load(scene_path) as PackedScene
	if not scene:
		return {}
	
	var instance = scene.instantiate()
	if not instance:
		return {}
	
	var scene_data = {
		"path": scene_path,
		"root_node": parse_node_recursive(instance)
	}
	
	instance.queue_free()
	return scene_data

func parse_node_recursive(node: Node) -> Dictionary:
	var node_data = {
		"name": node.name,
		"type": node.get_class(),
		"script": "",
		"properties": {},
		"groups": [],
		"children": []
	}
	
	# Get script path if attached
	if node.get_script():
		node_data.script = node.get_script().resource_path
	
	# Get non-default properties
	node_data.properties = get_non_default_properties(node)
	
	# Get groups
	for group in node.get_groups():
		node_data.groups.append(group)
	
	# Process children
	for child in node.get_children():
		node_data.children.append(parse_node_recursive(child))
	
	return node_data

func get_non_default_properties(node: Node) -> Dictionary:
	var properties = {}
	
	# Create a default instance of the same type for comparison
	var default_node = null
	var node_class = node.get_class()
	
	# Try to create default instance
	if ClassDB.can_instantiate(node_class):
		default_node = ClassDB.instantiate(node_class)
	
	if not default_node:
		return properties
	
	# Get all properties
	var property_list = node.get_property_list()
	
	for prop in property_list:
		# Only include editor-visible properties that aren't built-in engine properties
		if (prop.usage & PROPERTY_USAGE_EDITOR) and not prop.name.begins_with("_"):
			var current_value = node.get(prop.name)
			var default_value = default_node.get(prop.name)
			
			# Compare values (handle different types appropriately)
			if not values_equal(current_value, default_value):
				properties[prop.name] = serialize_value(current_value)
	
	default_node.queue_free()
	return properties

func values_equal(a, b) -> bool:
	# Handle Vector2, Vector3, Color, etc.
	if typeof(a) != typeof(b):
		return false
	
	if a is Vector2 or a is Vector3 or a is Vector4:
		return a.is_equal_approx(b)
	elif a is Color:
		return a.is_equal_approx(b)
	else:
		return a == b

func serialize_value(value):
	# Convert complex types to serializable formats
	if value is Vector2:
		return [value.x, value.y]
	elif value is Vector3:
		return [value.x, value.y, value.z]
	elif value is Vector4:
		return [value.x, value.y, value.z, value.w]
	elif value is Color:
		return [value.r, value.g, value.b, value.a]
	elif value is Resource and value.resource_path != "":
		return value.resource_path
	else:
		return value

func extract_script_info(script_path: String) -> Dictionary:
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var script_data = {
		"path": script_path,
		"language": script_path.get_extension(),
		"content": content,
		"exports": extract_exported_variables(content),
		"signals": extract_signals(content),
		"functions": extract_functions(content)
	}
	
	return script_data

func extract_exported_variables(content: String) -> Array:
	var exports = []
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("@export"):
			exports.append(line)
	
	return exports

func extract_signals(content: String) -> Array:
	var signals = []
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("signal "):
			signals.append(line)
	
	return signals

func extract_functions(content: String) -> Array:
	var functions = []
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("func "):
			functions.append(line)
	
	return functions

func get_autoloads() -> Dictionary:
	var autoloads = {}
	
	# Get autoload settings from project settings
	var settings = ProjectSettings.get_property_list()
	
	for setting in settings:
		if setting.name.begins_with("autoload/"):
			var autoload_name = setting.name.substr(9)  # Remove "autoload/" prefix
			var autoload_path = ProjectSettings.get_setting(setting.name)
			autoloads[autoload_name] = autoload_path
	
	return autoloads

func get_relevant_project_settings() -> Dictionary:
	var settings = {
		"application": {},
		"display": {},
		"input": {},
		"physics": {},
		"rendering": {}
	}
	
	# Application settings
	settings.application["name"] = ProjectSettings.get_setting("application/config/name", "")
	settings.application["description"] = ProjectSettings.get_setting("application/config/description", "")
	settings.application["main_scene"] = ProjectSettings.get_setting("application/run/main_scene", "")
	
	# Display settings
	settings.display["width"] = ProjectSettings.get_setting("display/window/size/viewport_width", 0)
	settings.display["height"] = ProjectSettings.get_setting("display/window/size/viewport_height", 0)
	
	# Input map
	var input_map = {}
	for action in InputMap.get_actions():
		input_map[action] = []
		for event in InputMap.action_get_events(action):
			input_map[action].append(str(event))
	settings.input["map"] = input_map
	
	return settings
