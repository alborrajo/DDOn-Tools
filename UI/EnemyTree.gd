extends Tree
class_name EnemyTree

export (String, FILE, "*.csv") var enemyCSV := "res://resources/enemies.csv"

func _ready():	
	hide_root = true
	var root := create_item()
	
	var file := File.new()
	file.open(enemyCSV, File.READ)
	file.get_csv_line() # Ignore header line
	while !file.eof_reached():
		var csv_line := file.get_csv_line()
		if csv_line.size() >= 3:
			var enemy := EnemyType.new(csv_line[0].hex_to_int(), csv_line[1], int(csv_line[2]))
			var enemy_item := create_item(root)
			enemy_item.set_text(0, enemy.name)
			enemy_item.set_metadata(0, enemy)
	file.close()	
	
func get_drag_data(position):
	var selected_enemy_type: EnemyType =  get_item_at_position(position).get_metadata(0)
	print_debug("Dragging %s" % [tr(selected_enemy_type.name)])
	return selected_enemy_type

func get_enemy_by_id(id: int) -> EnemyType:
	# Also inefficient af
	var child := get_root().get_children()
	while child != null:
		var enemy := child.get_metadata(0) as EnemyType
		if enemy.id == id:
			return enemy
		child = child.get_next()
	
	return null
