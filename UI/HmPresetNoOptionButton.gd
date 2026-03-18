extends OptionButton
class_name HmPresetNoOptionButton

const TRANSLATION_KEY_FORMAT = "HM_PRESET_NO_%s"

@export var named_param_csv := "res://resources/HmPresetNo.csv" # (String, FILE, "*.csv")

func _ready():
	# Godot 4 migration
	# File is now FileAccess and open() is now a static method that returns such object. To then check for errors, call file_access.get_error()
	# var file := File.new()
	# assert(file.open(named_param_csv, File.READ) == OK)
	var file := FileAccess.open(named_param_csv, FileAccess.READ)
	#debug
	print(named_param_csv)
	assert(FileAccess.get_open_error() == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 2:
			add_item(tr(TRANSLATION_KEY_FORMAT % csv_line[0]), int(csv_line[0]))
	file.close()
