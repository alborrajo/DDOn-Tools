extends OptionButton
class_name NamedEnemyParamsIdOptionButton

const TRANSLATION_KEY_FORMAT = "NAMED_PARAM_%s"

export (String, FILE, "*.csv") var named_param_csv := "res://resources/named_param.csv"

func _ready():
	var file := File.new()
	file.open(named_param_csv, File.READ)
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 1:
			add_item(tr(TRANSLATION_KEY_FORMAT % csv_line[0]), int(csv_line[0]))
	file.close()

func select(idx: int):
	var index := idx
	if index == -1:
		index = get_item_index(0x8FA)
	return .select(index)
