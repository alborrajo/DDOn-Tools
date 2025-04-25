extends ToggleablePlacemark
class_name ToggleableEnemySubgroupPlacemark

signal enemy_subgroup_mouse_entered(position_index, enemy_position_placemark)
signal enemy_subgroup_mouse_exited(position_index, enemy_position_placemark)

const EnemyPositionPlacemarkScene = preload("res://UI/Marker/EnemyPositionPlacemark.tscn")

var enemy_set: EnemySet
var enemy_subgroup: EnemySubgroup

func _ready():
	assert(SelectedListManager.connect("enemy_filter_changed", self, "_on_enemy_filter_changed") == OK)
	
	assert(enemy_subgroup.connect("changed", self, "_on_enemy_subgroup_changed") == OK)
	_on_enemy_subgroup_changed()
	
	for position_index in enemy_subgroup.positions.size():
		var enemy_position: EnemyPosition = enemy_subgroup.positions[position_index]
		var enemy_position_placemark: EnemyPositionPlacemark = EnemyPositionPlacemarkScene.instance()
		assert(enemy_position_placemark.connect("mouse_entered", self, "_on_enemy_position_placemark_mouse_entered", [position_index, enemy_position_placemark]) == OK)
		assert(enemy_position_placemark.connect("mouse_exited", self, "_on_enemy_position_placemark_mouse_exited", [position_index, enemy_position_placemark]) == OK)
		enemy_position_placemark.enemy_position = enemy_position
		var map_control := MapControl.new()
		map_control.set_ddon_world_position(DataProvider.stage_id_to_stage_no(enemy_set.stage_id), enemy_position.coordinates)
		map_control.add_child(enemy_position_placemark)
		map_control.mouse_filter = MOUSE_FILTER_PASS
		$EnemyPositionPlacemarksControl.add_child(map_control)
	
	# TODO: Calcualte group center instead of using the first position
	$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(enemy_set.stage_id), enemy_subgroup.positions[0].coordinates)
	
func _on_enemy_subgroup_changed():
	$MapControl/ToggleButton.text = "%d - %d/%d" % [enemy_set.group_id, enemy_subgroup.effective_enemy_count(), enemy_subgroup.positions.size()]
	$MapControl/ToggleButton/WarningLabel.visible = false
	for position in enemy_subgroup.positions:
		if position.has_conflicting_enemy_times():
			$MapControl/ToggleButton/WarningLabel.visible = true
			break
			
func _process(_delta):
	$EnemyPositionPlacemarksControl.visible = $MapControl/Control.visible

func _on_Control_mouse_entered():
	emit_signal("enemy_subgroup_mouse_entered", -1, null)

func _on_Control_mouse_exited():
	emit_signal("enemy_subgroup_mouse_exited", -1, null)
	
func _on_ToggleButton_mouse_entered():
	emit_signal("enemy_subgroup_mouse_entered", -1, null)
	
func _on_ToggleButton_mouse_exited():
	emit_signal("enemy_subgroup_mouse_exited", -1, null)
	
func _on_enemy_position_placemark_mouse_entered(position_index: int, enemy_position_placemark: EnemyPositionPlacemark):
	emit_signal("enemy_subgroup_mouse_entered", position_index, enemy_position_placemark)
	
func _on_enemy_position_placemark_mouse_exited(position_index: int, enemy_position_placemark: EnemyPositionPlacemark):
	emit_signal("enemy_subgroup_mouse_exited", position_index, enemy_position_placemark)

func get_position_placemarks() -> Array:
	return $EnemyPositionPlacemarksControl.get_children()

func _on_SubgroupButton_subgroup_selected():
	show()
	for child in $EnemyPositionPlacemarksControl.get_children():
		assert(child.get_child(0) is EnemyPositionPlacemark)
		var position := child.get_child(0) as EnemyPositionPlacemark
		position.select_all_placemarks()

func _on_enemy_filter_changed(uppercase_filter_text: String):
	for position in enemy_subgroup.positions:
		for enemy in position.enemies:
			if enemy.enemy_type.matches_filter_text(uppercase_filter_text):
				modulate = SelectedListManager.FILTER_MATCH_COLOR
				return
	modulate = SelectedListManager.FILTER_NONMATCH_COLOR


func _on_EnemyPositionPlacemarksControl_gui_input(event):
	._on_Control_gui_input(event)
