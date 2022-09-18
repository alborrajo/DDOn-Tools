extends PanelContainer
class_name EnemySetPlacemark

export (PackedScene) var enemy_placemark_packed_scene: PackedScene = preload("res://UI/Marker/EnemyPlacemark.tscn")

export var stage_id: int
export var layer_no: int
export var group_id: int
export var subgroup_id: int

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].zoom.x
onready var _original_scale := rect_scale

func add_enemy(enemy: Enemy) -> void:
	var enemy_placemark: EnemyPlacemark = enemy_placemark_packed_scene.instance()
	enemy_placemark.enemy = enemy
	$VBoxContainer.add_child(enemy_placemark)

func clear_enemies() -> void:
	for child in $VBoxContainer.get_children():
		child.queue_free()

func get_enemies() -> Array:
	var enemies := []
	for child in $VBoxContainer.get_children():
		if child is EnemyPlacemark:
			var enemy_placemark := child as EnemyPlacemark
			enemies.append(enemy_placemark.enemy)
	return enemies

func can_drop_data(position, data):
	return data is EnemyType
	
func drop_data(position, data):
	add_enemy(Enemy.new(data))
	print_debug("Placed %s at %s (%d %d %d %d) " % [tr(data.name), tr(str("STAGE_NAME_",stage_id)), stage_id, layer_no, group_id, subgroup_id])

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	rect_scale = _original_scale * clamp(camera_zoom, 0, _original_zoom)
