extends ScrollContainer
class_name EnemyDetailsPanel

const COLOR_BLOOD_ORB = Color.violet
const COLOR_HIGH_ORB = Color.orangered
const COLOR_DEFAULT = Color.white

export (NodePath) var title_label: NodePath

var enemy: Enemy setget _set_enemy
var supress_event = true

onready var title_label_node: Label = get_node_or_null(title_label)

func _set_enemy(em: Enemy) -> void:
	if enemy != null and enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
	
	enemy = em
	
	if em != null:
		assert(em.connect("changed", self, "_on_enemy_changed") == OK)
		
	supress_event = true
	_on_enemy_changed()
	supress_event = false

	# this bridges the logic over to dropscontroller, the refreshing is handled there.
func _refresh_selected_name():
		$VBoxContainer/DropsController._refresh_filter()
	
func _on_enemy_changed():
	if enemy != null:
		# Cloning first prevents values from getting overwritten by events
		# happening while being set in the UI
		# For example: Setting LevelLineEdit.value triggers a signal, which sets
		# the enemy.lv property, which resets the HO/BO/Exp values before they
		# are written to the UI.
		# Using a clone means that even if the values in the enemy variable are
		# changed, the values in enemy_clone are still the originals
		var filter_text = $VBoxContainer/DropsController._current_filter_text
		var enemy_clone := enemy.clone()
		$VBoxContainer/NamedParamsControl/HBoxContainer/NamedEnemyParamsIdOptionButton.select_by_id(enemy_clone.named_param.id)
		$VBoxContainer/GridContainer/RaidBossIdLineEdit.value = enemy_clone.raid_boss_id
		$VBoxContainer/GridContainer/ScaleLineEdit.value = enemy_clone.scale
		$VBoxContainer/GridContainer/LevelLineEdit.value = enemy_clone.lv
		$VBoxContainer/GridContainer/HmPresetNoOptionButton.select($VBoxContainer/GridContainer/HmPresetNoOptionButton.get_item_index(enemy_clone.hm_preset_no))
		$VBoxContainer/GridContainer/StartThinkTblNoLineEdit.value = enemy_clone.start_think_tbl_no
		$VBoxContainer/GridContainer/RepopNumLineEdit.value = enemy_clone.repop_num
		$VBoxContainer/GridContainer/RepopCountLineEdit.value = enemy_clone.repop_count
		$VBoxContainer/GridContainer/EnemyTargetTypesIdLineEdit.select($VBoxContainer/GridContainer/EnemyTargetTypesIdLineEdit.get_item_index(enemy_clone.enemy_target_types_id))
		$VBoxContainer/GridContainer/MontageFixNoLineEdit.value = enemy_clone.montage_fix_no
		$VBoxContainer/GridContainer/SetTypeLineEdit.value = enemy_clone.set_type
		$VBoxContainer/GridContainer/InfectionTypeLineEdit.select($VBoxContainer/GridContainer/InfectionTypeLineEdit.get_item_index(enemy_clone.infection_type))
		$VBoxContainer/GridContainer/SpawnTimeTypeLineEdit.select($VBoxContainer/GridContainer/SpawnTimeTypeLineEdit.get_item_index(enemy_clone.time_type))
		$VBoxContainer/GridContainer/CustomTimeTypeLineEdit.text = enemy_clone.custom_time
		$VBoxContainer/GridContainer/IsBossGauge.pressed = enemy_clone.is_boss_gauge
		$VBoxContainer/GridContainer/IsBossBGM.pressed = enemy_clone.is_boss_bgm
		$VBoxContainer/GridContainer/IsManualSet.pressed = enemy_clone.is_manual_set
		$VBoxContainer/GridContainer/IsAreaBoss.pressed = enemy_clone.is_area_boss
		$VBoxContainer/GridContainer/IsBloodEnemy.pressed = enemy_clone.is_blood_enemy
		$VBoxContainer/GridContainer/BloodOrbsContainer/DoesDropBO.pressed = enemy_clone.does_drop_bo
		$VBoxContainer/GridContainer/BloodOrbsContainer/BloodOrbsSpinBox.editable = enemy_clone.does_drop_bo
		$VBoxContainer/GridContainer/BloodOrbsContainer/BloodOrbsSpinBox.value = enemy_clone.blood_orbs
		$VBoxContainer/GridContainer/IsHighOrbEnemy.pressed = enemy_clone.is_highorb_enemy
		$VBoxContainer/GridContainer/HighOrbsContainer/DoesDropHO.pressed = enemy_clone.does_drop_ho
		$VBoxContainer/GridContainer/HighOrbsContainer/HighOrbsSpinBox.editable = enemy_clone.does_drop_ho
		$VBoxContainer/GridContainer/HighOrbsContainer/HighOrbsSpinBox.value = enemy_clone.high_orbs
		$VBoxContainer/ExpContainer/NamedParamsExpPercentageLabel.text = String(enemy_clone.named_param.experience)
		$VBoxContainer/ExpContainer/ExpSpinBox.value = enemy_clone.experience
		$VBoxContainer/PpContainer/NamedParamsPpPercentageLabel.text = String(enemy_clone.play_points)
		$VBoxContainer/PpContainer/PpSpinBox.value = enemy_clone.play_points
		_refresh_selected_name()
		if enemy_clone.drops_table == null:
			$VBoxContainer/DropsController.select_drops_table(-1, true)
		else:
			$VBoxContainer/DropsController.select_drops_table(enemy_clone.drops_table.id, true)
			
		
		if title_label_node != null:
			var list_count = SelectedListManager.selected_list
			if list_count.size() > 1:
				title_label_node.text = "Selected Nodes: " + str(list_count.size())
			else:
				if enemy.named_param.type == NamedParam.Type.NAMED_TYPE_REPLACE:
					title_label_node.text = "%s (%s)" % [enemy.get_display_name(), enemy.enemy_type.name]
				else:
					title_label_node.text = enemy.get_display_name()
				# TODO: Set id and position index
				
			if enemy_clone.is_blood_enemy:
				title_label_node.modulate = COLOR_BLOOD_ORB
			elif enemy_clone.is_highorb_enemy:
				title_label_node.modulate = COLOR_HIGH_ORB
			else: 
				title_label_node.modulate = COLOR_DEFAULT
				
		$VBoxContainer/GridContainer/CustomTimeType.visible = enemy.time_type == 3
		$VBoxContainer/GridContainer/CustomTimeTypeLineEdit.visible = enemy.time_type == 3
		$VBoxContainer/DropsController._on_DropsFilterLineEdit_text_changed(filter_text)
		# Critical this comes after everything to ensure the filters get applied



func _on_NamedEnemyParamsIdOptionButton_item_selected(index):
	var value = $VBoxContainer/NamedParamsControl/HBoxContainer/NamedEnemyParamsIdOptionButton.get_item_metadata(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("named_param", value)

func _on_RaidBossIdLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("raid_boss_id", value)

func _on_ScaleLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("scale", value)

func _on_LevelLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("lv", value)

func _on_HmPresetNoOptionButton_item_selected(index):
	var value = $VBoxContainer/GridContainer/HmPresetNoOptionButton.get_item_id(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("hm_preset_no", value)

func _on_StartThinkTblNoLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("start_think_tbl_no", value)

func _on_RepopNumLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("repop_num", value)

func _on_RepopCountLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("repop_count", value)

func _on_EnemyTargetTypesIdLineEdit_item_selected(index):
	var value = $VBoxContainer/GridContainer/EnemyTargetTypesIdLineEdit.get_item_id(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("enemy_target_types_id", value)

func _on_MontageFixNoLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("montage_fix_no", value)

func _on_SetTypeLineEdit_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("set_type", value)

func _on_InfectionTypeLineEdit_item_selected(index):
	var value = $VBoxContainer/GridContainer/InfectionTypeLineEdit.get_item_id(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("infection_type", value)

func _on_SpawnTimeTypeLineEdit_item_selected(index):
	var value = $VBoxContainer/GridContainer/SpawnTimeTypeLineEdit.get_item_id(index)
	if supress_event != true:
			SelectedListManager.apply_values_to_selection("time_type", value)

func _on_IsBossGauge_pressed():
	var value = $VBoxContainer/GridContainer/IsBossGauge.pressed 
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_boss_gauge", value)

func _on_IsBossBGM_pressed():
	var value = $VBoxContainer/GridContainer/IsBossBGM.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_boss_bgm", value)
		
func _on_IsManualSet_pressed():
	var value = $VBoxContainer/GridContainer/IsManualSet.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_manual_set", value)

func _on_IsAreaBoss_pressed():
	var value = $VBoxContainer/GridContainer/IsAreaBoss.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_area_boss", value)

func _on_DoesDropBO_pressed():
	var value = $VBoxContainer/GridContainer/BloodOrbsContainer/DoesDropBO.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("does_drop_bo", value)

func _on_DoesDropHO_pressed():
	var value = $VBoxContainer/GridContainer/HighOrbsContainer/DoesDropHO.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("does_drop_ho", value)

func _on_IsBloodEnemy_pressed():
	var value = $VBoxContainer/GridContainer/IsBloodEnemy.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_blood_enemy", value)

func _on_IsHighOrbEnemy_pressed():
	var value = $VBoxContainer/GridContainer/IsHighOrbEnemy.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_highorb_enemy", value)

func _on_BloodOrbsSpinBox_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("blood_orbs", value)

func _on_HighOrbsSpinBox_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("high_orbs", value)

func _on_ExpSpinBox_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("experience", value)

func _on_PpSpinBox_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("play_points", value)


func _on_DropsContainer_drops_table_selected(drops_table):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("drops_table", drops_table)

func _on_CustomTimeTypeLineEdit_text_changed(text):
	enemy.custom_time = text
	# Verify if the new text passed validations
	if enemy.custom_time != text:
		$VBoxContainer/GridContainer/CustomTimeTypeLineEdit.add_color_override("font_color", Color.red)
	elif supress_event != true:
		$VBoxContainer/GridContainer/CustomTimeTypeLineEdit.remove_color_override("font_color")
		SelectedListManager.apply_values_to_selection("custom_time", enemy.custom_time)



