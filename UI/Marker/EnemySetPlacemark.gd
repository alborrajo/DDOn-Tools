extends GenericSetPlacemark
class_name EnemySetPlacemark

export (PackedScene) var enemy_placemark_packed_scene: PackedScene = preload("res://UI/Marker/EnemyPlacemark.tscn")

export (Resource) var enemy_set: Resource

onready var _enemy_set := enemy_set as EnemySet
onready var set_tod_value = 0

func _ready() -> void:
	_enemy_set.connect("changed", self, "_on_enemy_set_changed")
	SetProvider.connect("selected_day_night", self, "_on_selected_day_night")
	_on_enemy_set_changed()
	
func _on_selected_day_night(tod_index: int):
	set_tod_value = tod_index
	
func _on_enemy_set_changed() -> void:
	# Rebuild children elements
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		
	for index in _enemy_set.get_enemies().size():
		var enemy: Enemy = _enemy_set.get_enemies()[index]
		var enemy_placemark: EnemyPlacemark = enemy_placemark_packed_scene.instance()
		enemy_placemark.enemy = enemy
		enemy_placemark.connect("placemark_removed", self, "_on_enemy_removed", [index])
		$VBoxContainer.add_child(enemy_placemark)

func _on_enemy_removed(index: int) -> void:
	_enemy_set.remove_enemy(index)
	SetProvider.select_day_night(set_tod_value)
	

func add_enemy(enemy: Enemy) -> void:
	_enemy_set.add_enemy(enemy)
	SetProvider.select_day_night(set_tod_value)

func clear_enemies() -> void:
	_enemy_set.clear_enemies()

func get_enemies() -> Array:
	return _enemy_set.get_enemies()

# Drag and drop functions
func can_drop_data(_position, data):
	return data is EnemyType
	
func drop_data(_position, data):
	add_enemy(Enemy.new(data))
	print_debug("Placed %s at %s (%d %d %d %d) " % [tr(data.name), tr(str("STAGE_NAME_",_enemy_set.stage_id)), _enemy_set.stage_id, _enemy_set.layer_no, _enemy_set.group_id, _enemy_set.subgroup_id])
