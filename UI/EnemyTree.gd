extends Tree
class_name EnemyTree

export (String, FILE, "*.csv") var enemyCSV := "res://resources/enemies.csv"

var enemy_cache: Array
var initialized := false

func _ready():
	init_enemy_list()
		
func init_enemy_list():
	if initialized:
		return
		
	enemy_cache = []
	var file := File.new()
	assert(file.open(enemyCSV, File.READ) == OK)
	# warning-ignore:return_value_discarded
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 3:
			var enemy := EnemyType.new(csv_line[0].hex_to_int(), int(csv_line[2]))
			enemy_cache.append(enemy)
	file.close()
	_rebuild_list()
	initialized = true
	
func _on_FilterLineEdit_text_changed(new_text):
	_rebuild_list(new_text)
	
func _rebuild_list(filter_text: String = ""):
	var normalized_filter_text = filter_text.to_upper()
	var filter_int = -1
	var filter_hex = -1

	if filter_text.is_valid_integer():
		filter_int = int(filter_text)
	elif filter_text.is_valid_hex_number(true): # true is to check with prefix
		filter_hex = int(filter_text)

	clear()
	hide_root = true
	var root = create_item()
	for enemy in enemy_cache:
		if normalized_filter_text.length() == 0:
			_populate_list(root, enemy)
		elif filter_int != -1 and filter_int == enemy.id:
			_populate_list(root, enemy)
		elif filter_hex != -1:
			var enemy_hex = int("0x%06X" % enemy.id)# Converting back to Hex
			if filter_hex == enemy_hex:
				_populate_list(root, enemy)
		elif normalized_filter_text in enemy.name.to_upper():
			_populate_list(root, enemy)


# exists to reduce duplicate code
func _populate_list(root, enemy):
	var enemy_item = create_item(root)
	enemy_item.set_text(0, "%s [0x%06X]" % [enemy.name, enemy.id]) # Displaying name and ID
	enemy_item.set_metadata(0, enemy)

func get_drag_data(position):
	var selected_enemy_type: EnemyType =  get_item_at_position(position).get_metadata(0)
	print_debug("Dragging %s" % [tr(selected_enemy_type.name)])
	return selected_enemy_type

func get_enemy_by_id(id: int) -> EnemyType:
	# Also inefficient af
	for enemy_type in enemy_cache:
		if enemy_type.id == id:
			return enemy_type
	printerr("Couldn't find enemy with id", id)
	return null
