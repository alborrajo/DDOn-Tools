extends PanelContainer
class_name EnemySetPlacemark

export (PackedScene) var enemy_placemark_packed_scene: PackedScene = preload("res://UI/Marker/EnemyPlacemark.tscn")

export (Resource) var enemy_set: Resource

onready var _enemy_set := enemy_set as EnemySet

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
onready var _original_scale := rect_scale

func _ready() -> void:
	_enemy_set.connect("changed", self, "_on_enemy_set_changed")
	_on_enemy_set_changed()
	
func _on_enemy_set_changed() -> void:
	# Rebuild children elements
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		
	for enemy in _enemy_set.get_enemies():
		var enemy_placemark: EnemyPlacemark = enemy_placemark_packed_scene.instance()
		enemy_placemark.enemy = enemy
		$VBoxContainer.add_child(enemy_placemark)
	

func add_enemy(enemy: Enemy) -> void:
	_enemy_set.add_enemy(enemy)

func clear_enemies() -> void:
	_enemy_set.clear_enemies()

func get_enemies() -> Array:
	return _enemy_set.get_enemies()

# Drag and drop functions
func can_drop_data(position, data):
	return data is EnemyType
	
func drop_data(position, data):
	add_enemy(Enemy.new(data))
	print_debug("Placed %s at %s (%d %d %d %d) " % [tr(data.name), tr(str("STAGE_NAME_",_enemy_set.stage_id)), _enemy_set.stage_id, _enemy_set.layer_no, _enemy_set.group_id, _enemy_set.subgroup_id])


func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	rect_scale = _original_scale * clamp(camera_zoom, 0, _original_zoom)
