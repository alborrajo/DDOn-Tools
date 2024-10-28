extends Control
class_name EnemySubgroupPlacemark

signal subgroup_mouse_entered(position_index, enemy_position_placemark)
signal subgroup_mouse_exited(position_index, enemy_position_placemark)

const EnemyPositionPlacemarkScene = preload("res://UI/Marker/EnemyPositionPlacemark.tscn")

var enemy_set: EnemySet
var enemy_subgroup: EnemySubgroup

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
onready var _button_original_scale: Vector2 = $SubgroupButtonControl.rect_scale

func _ready():
	assert(enemy_subgroup.connect("changed", self, "_on_enemy_subgroup_changed") == OK)
	_on_enemy_subgroup_changed()
	
	for position_index in enemy_subgroup.positions.size():
		var enemy_position: EnemyPosition = enemy_subgroup.positions[position_index]
		var map_entity = MapEntity.new(enemy_position.coordinates, DataProvider.stage_id_to_stage_no(enemy_set.stage_id))
		var enemy_position_placemark: EnemyPositionPlacemark = EnemyPositionPlacemarkScene.instance()
		enemy_position_placemark.rect_position = map_entity.get_map_position()*1000
		assert(enemy_position_placemark.connect("mouse_entered", self, "_on_enemy_position_placemark_mouse_entered", [position_index, enemy_position_placemark]) == OK)
		assert(enemy_position_placemark.connect("mouse_exited", self, "_on_enemy_position_placemark_mouse_exited", [position_index, enemy_position_placemark]) == OK)
		enemy_position_placemark.enemy_position = enemy_position
		assert(enemy_position_placemark.connect("gui_input", self, "_on_EnemyPositionPlacemark_gui_input") == OK)
		$EnemyPositionPlacemarksControl.add_child(enemy_position_placemark)
	
	# TODO: Calcualte group center instead of using the first position
	$SubgroupButtonControl.rect_position = $EnemyPositionPlacemarksControl.get_child(0).rect_position

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	$SubgroupButtonControl.rect_scale = _button_original_scale * clamp(camera_zoom, 0, _original_zoom)
	
func _on_enemy_subgroup_changed():
	$SubgroupButtonControl/SubgroupButton.text = "%d - %d/%d" % [enemy_set.group_id, enemy_subgroup.effective_enemy_count(), enemy_subgroup.positions.size()]
	$SubgroupButtonControl/WarningLabel.visible = false
	for position in enemy_subgroup.positions:
		if position.has_conflicting_enemy_times():
			$SubgroupButtonControl/WarningLabel.visible = true
			break

func _on_GroupButton_mouse_entered():
	emit_signal("subgroup_mouse_entered", -1, null)

func _on_GroupButton_mouse_exited():
	emit_signal("subgroup_mouse_exited", -1, null)
	
func _on_enemy_position_placemark_mouse_entered(position_index: int, enemy_position_placemark: EnemyPositionPlacemark):
	emit_signal("subgroup_mouse_entered", position_index, enemy_position_placemark)
	
func _on_enemy_position_placemark_mouse_exited(position_index: int, enemy_position_placemark: EnemyPositionPlacemark):
	emit_signal("subgroup_mouse_exited", position_index, enemy_position_placemark)

func _on_GroupButton_pressed():
	show_positions()
	
func _on_EnemyPositionPlacemark_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE and event.pressed:
			hide_positions()

func get_position_placemarks() -> Array:
	return $EnemyPositionPlacemarksControl.get_children()
	
func show_positions() -> void:
	$SubgroupButtonControl.visible = false
	$EnemyPositionPlacemarksControl.visible = true
	
func hide_positions() -> void:
	$SubgroupButtonControl.visible = true
	$EnemyPositionPlacemarksControl.visible = false
