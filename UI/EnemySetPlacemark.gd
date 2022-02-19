extends PanelContainer
class_name EnemySetPlacemark

export (PackedScene) var enemy_placemark_packed_scene: PackedScene = load("res://UI/EnemyPlacemark.tscn")

export var stage_id: int
export var layer_no: int
export var group_id: int
export var subgroup_id: int

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

func _process(_delta):
	rect_scale = _original_scale * get_tree().get_nodes_in_group("camera")[0].zoom.x

static func get_scaled_global_rect(control: Control) -> Rect2:
	var global_rect := control.get_global_rect()
	return Rect2(global_rect.position, global_rect.size*control.rect_scale)
