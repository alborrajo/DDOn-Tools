extends GenericSetPlacemark
class_name EnemyPositionPlacemark

export (PackedScene) var enemy_placemark_packed_scene: PackedScene = preload("res://UI/Marker/EnemyPlacemark.tscn")

var enemy_position: EnemyPosition setget _set_enemy_position

onready var _warning_full_text: String = $WarningLabel.text

func _on_enemy_position_changed() -> void:
	# Rebuild children elements
	for child in $Panel/Container.get_children():
		$Panel/Container.remove_child(child)
		
	if enemy_position != null: 
		for enemy_idx in enemy_position.enemies.size():
			var enemy: Enemy = enemy_position.enemies[enemy_idx]
			var enemy_placemark: EnemyPlacemark = enemy_placemark_packed_scene.instance()
			enemy_placemark.enemy = enemy
			assert(enemy_placemark.connect("placemark_removed", self, "_on_enemy_removed", [enemy_idx]) == OK)
			$Panel/Container.add_child(enemy_placemark)

	_check_position_conflicts()

func _on_enemy_changed(_enemy: Enemy) -> void:
	_check_position_conflicts()

func _set_enemy_position(new_enemy_position: EnemyPosition) -> void:
	if enemy_position != null:
		if enemy_position.is_connected("changed", self, "_on_enemy_position_changed"):
			enemy_position.disconnect("changed", self, "_on_enemy_position_changed")
		for enemy in enemy_position.get_enemies():
			if enemy_position.is_connected("changed", self, "_on_enemy_changed"):
				enemy_position.disconnect("changed", self, "_on_enemy_changed")
	
	enemy_position = new_enemy_position
	
	if enemy_position != null:
		assert(enemy_position.connect("changed", self, "_on_enemy_position_changed") == OK)

	_on_enemy_position_changed()

func _on_enemy_removed(enemy_idx: int) -> void:
	var enemy: Enemy = enemy_position.enemies[enemy_idx]
	if enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
	enemy_position.remove_enemy(enemy_idx)

func add_enemy(enemy: Enemy) -> void:
	enemy_position.add_enemy(enemy)

func clear_enemies() -> void:
	enemy_position.clear_enemies()

func get_enemies() -> Array:
	return enemy_position.enemies

# Drag and drop functions
func can_drop_data(_position, data):
	return data is EnemyType or data is Enemy
	
func drop_data(_position, data):
	if data is Enemy:
		add_enemy(data)
	elif data is EnemyType:
		add_enemy(Enemy.new(data))

func _check_position_conflicts() -> void:
	var exceeded := enemy_position.has_conflicting_enemy_times()
	$WarningLabel.visible = exceeded
	if exceeded:
		$WarningLabel.mouse_filter = Control.MOUSE_FILTER_PASS

# Bad homemade tooltip-like behavior since the normal tooltip doesnt show up
func _on_WarningLabel_mouse_entered():
	$WarningLabel.text = _warning_full_text
func _on_WarningLabel_mouse_exited():
	$WarningLabel.text = _warning_full_text.left(1)
func _on_WarningLabel_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		_on_WarningLabel_mouse_exited()
		$WarningLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
