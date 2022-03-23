extends Tree
class_name EnemyTree

export (String, FILE, "*.csv") var enemyCSV := "res://resources/enemies.csv"

var _dragging := false

func _ready():
	connect("item_selected", self, "_on_item_selected")
	
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

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed() and _dragging:
		_dragging = false;
		print_debug("dragging", _dragging)
		
		for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
			if node is EnemySetPlacemark and (node as EnemySetPlacemark).is_visible_in_tree() and EnemySetPlacemark.get_scaled_global_rect(node).has_point(node.get_global_mouse_position()):
				var placemark := node as EnemySetPlacemark
				var selected_enemy_type := get_selected().get_metadata(get_selected_column()) as EnemyType
				var enemy := Enemy.new(selected_enemy_type)
				placemark.add_enemy(enemy)
				print_debug("selected enemy type", selected_enemy_type)
				break

func _on_item_selected():
	_dragging = true
	print_debug("dragging", _dragging)

func get_enemy_by_id(id: int) -> EnemyType:
	# Also inefficient af
	var child := get_root().get_children()
	while child != null:
		var enemy := child.get_metadata(0) as EnemyType
		if enemy.id == id:
			return enemy
		child = child.get_next()
	
	return null
