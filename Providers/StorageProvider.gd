extends Node

const STORAGE_FILE := "user://config.ini"

var config = ConfigFile.new()

func _ready():
	# Load data from a file.
	var err = config.load(STORAGE_FILE)
	print(ProjectSettings.globalize_path("user://"))
	if err == OK:
		return
	elif err == ERR_FILE_NOT_FOUND:
		print("Config file not found, a new one will be created", STORAGE_FILE, err)
	else:
		printerr("Failed to load config file", STORAGE_FILE, err)

func _init_settings():
	#config.set_value("null", "null", null)
	pass


func has_section_key(section: String, key: String) -> bool:
	return config.has_section_key(section, key)

func get_value(section: String, key: String, default = null):
	return config.get_value(section, key, default)
	
func set_value(section: String, key: String, value):
	config.set_value(section, key, value)
	var err = config.save(STORAGE_FILE)
	if err != OK:
		printerr("Failed to save config file", STORAGE_FILE, err)
