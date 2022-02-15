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
		if csv_line.size() >= 2:
			var enemy := Enemy.new(csv_line[0], csv_line[1])
			var enemy_item := create_item(root)
			enemy_item.set_text(0, enemy.name)
			enemy_item.set_metadata(0, enemy)
	file.close()

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed() and _dragging:
		_dragging = false;
		print_debug("dragging", _dragging)
		
		for node in get_tree().get_nodes_in_group("EnemyPlacemark"):
			if node is EnemyPlacemark and node.get_scaled_global_rect().has_point(node.get_global_mouse_position()):
				var placemark := node as EnemyPlacemark
				var selected_enemy := get_selected().get_metadata(get_selected_column()) as Enemy
				placemark.set_enemy(selected_enemy)
				print_debug("selected enemy", selected_enemy)
				break

func _on_item_selected():
	_dragging = true
	print_debug("dragging", _dragging)

func get_enemy_by_id(id: String) -> Enemy:
	# Also inefficient af
	var child := get_root().get_children()
	while child != null:
		var enemy := child.get_metadata(0) as Enemy
		if enemy.id == id:
			return enemy
		child = child.get_next()
	
	return null
