extends RefCounted

class_name Common

static func load_json_file(path):
	"""Loads a JSON file from the given res path and return the loaded JSON object."""
	# Godot 4 migration
	# var file = File.new()
	# file.open(path, file.READ)
	var file = FileAccess.open(path, FileAccess.READ)
		#debug
	print(path)
	if file == null:
		push_error("[load_json_file] Could not open file: " + path)
		return null
	
	var text := file.get_as_text()
	file.close()
	# Godot 4 migration
	# New JSON-API
	# var test_json_conv = JSON.new()
	# test_json_conv.parse(text)
	# var result_json = test_json_conv.get_data()
	# if result_json.error != OK:
	#	print("[load_json_file] Error loading JSON file '" + str(path) + "'.")
	#	print("\tError: ", result_json.error)
	#	print("\tError Line: ", result_json.error_line)
	#	print("\tError String: ", result_json.error_string)
	#	return null
	#var obj = result_json.result
	#return obj
	var parse_result = JSON.parse_string(text)
	if parse_result == null:
		push_error("[load_json_file] Invalid JSON in file: " + path)
		return null
	return parse_result
	
static func save_json_file(path, contents):
	"""Saves contents to the given path as JSON."""
	# Godot 4 migration
	# var file = File.new()
	# file.open(path, file.WRITE)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(contents))
	file.close()
