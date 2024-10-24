extends OptionButton
class_name HmPresetNoOptionButton

const TRANSLATION_KEY_FORMAT = "HM_PRESET_NO_%s"

export (String, FILE, "*.csv") var named_param_csv := "res://resources/HmPresetNo.csv"

func _ready():
	var file := File.new()
	assert(file.open(named_param_csv, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 2:
			add_item(tr(TRANSLATION_KEY_FORMAT % csv_line[0]), int(csv_line[0]))
	file.close()
