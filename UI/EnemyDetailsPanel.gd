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
		em.connect("changed", self, "_on_enemy_changed")
		
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
		$VBoxContainer/GridContainer/EnemyTargetTypesIdLineEdit.value = enemy_clone.enemy_target_types_id
		$VBoxContainer/GridContainer/MontageFixNoLineEdit.value = enemy_clone.montage_fix_no
		$VBoxContainer/GridContainer/SetTypeLineEdit.value = enemy_clone.set_type
		$VBoxContainer/GridContainer/InfectionTypeLineEdit.select($VBoxContainer/GridContainer/InfectionTypeLineEdit.get_item_index(enemy_clone.infection_type))
		$VBoxContainer/GridContainer/SpawnTimeTypeLineEdit.select($VBoxContainer/GridContainer/SpawnTimeTypeLineEdit.get_item_index(enemy_clone.time_type))
		$VBoxContainer/GridContainer/CustomTimeTypeLineEdit.text = enemy_clone.custom_time
		$VBoxContainer/GridContainer/IsBossGauge.pressed = enemy_clone.is_boss_gauge
		$VBoxContainer/GridContainer/IsBossBGM.pressed = enemy_clone.is_boss_bgm
		$VBoxContainer/GridContainer/IsManualSet.pressed = enemy_clone.is_manual_set
		$VBoxContainer/GridContainer/IsAreaBoss.pressed = enemy_clone.is_area_boss
		$VBoxContainer/GridContainer/BloodOrbsContainer/IsBloodEnemy.pressed = enemy_clone.is_blood_enemy
		$VBoxContainer/GridContainer/BloodOrbsContainer/BloodOrbsSpinBox.editable = enemy_clone.is_blood_enemy
		$VBoxContainer/GridContainer/BloodOrbsContainer/BloodOrbsSpinBox.value = enemy_clone.blood_orbs
		$VBoxContainer/GridContainer/HighOrbsContainer/IsHighOrbEnemy.pressed = enemy_clone.is_highorb_enemy
		$VBoxContainer/GridContainer/HighOrbsContainer/HighOrbsSpinBox.editable = enemy_clone.is_highorb_enemy
		$VBoxContainer/GridContainer/HighOrbsContainer/HighOrbsSpinBox.value = enemy_clone.high_orbs
		$VBoxContainer/ExpContainer/NamedParamsExpPercentageLabel.text = String(enemy_clone.named_param.experience)
		$VBoxContainer/ExpContainer/ExpSpinBox.value = enemy_clone.experience
		_refresh_selected_name()
		if enemy_clone.drops_table == null:
			$VBoxContainer/DropsController.select_drops_table(-1, true)
		else:
			$VBoxContainer/DropsController.select_drops_table(enemy_clone.drops_table.id, true)
			
		
		# Duplicate code from EnemyPlacemark, where a similar thing is done.
		# TODO: thonk
		if title_label_node != null:
			var list_count = SelectedListManager.selected_list
			if list_count.size() > 1:
				title_label_node.text = "Selected Nodes: " + str(list_count.size())
			else:
				title_label_node.text = enemy_clone.get_display_name()
				
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
	enemy.named_param = $VBoxContainer/NamedParamsControl/HBoxContainer/NamedEnemyParamsIdOptionButton.get_item_metadata(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("named_param", enemy.named_param)

func _on_RaidBossIdLineEdit_value_changed(value):
	enemy.raid_boss_id = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("raid_boss_id", enemy.raid_boss_id)

func _on_ScaleLineEdit_value_changed(value):
	enemy.scale = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("scale", enemy.scale)

func _on_LevelLineEdit_value_changed(value):
	enemy.lv = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("lv", enemy.lv)

func _on_HmPresetNoOptionButton_item_selected(index):
	enemy.hm_preset_no = $VBoxContainer/GridContainer/HmPresetNoOptionButton.get_item_id(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("hm_preset_no", enemy.hm_preset_no)

func _on_StartThinkTblNoLineEdit_value_changed(value):
	enemy.start_think_tbl_no = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("start_think_tbl_no", enemy.start_think_tbl_no)

func _on_RepopNumLineEdit_value_changed(value):
	enemy.repop_num = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("repop_num", enemy.repop_num)

func _on_RepopCountLineEdit_value_changed(value):
	enemy.repop_count = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("repop_count", enemy.repop_count)

func _on_EnemyTargetTypesIdLineEdit_value_changed(value):
	enemy.enemy_target_types_id = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("enemy_target_types_id", enemy.enemy_target_types_id)

func _on_MontageFixNoLineEdit_value_changed(value):
	enemy.montage_fix_no = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("montage_fix_no", enemy.montage_fix_no)

func _on_SetTypeLineEdit_value_changed(value):
	enemy.set_type = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("set_type", enemy.set_type)

func _on_InfectionTypeLineEdit_item_selected(index):
	enemy.infection_type = $VBoxContainer/GridContainer/InfectionTypeLineEdit.get_item_id(index)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("infection_type", enemy.infection_type)

func _on_SpawnTimeTypeLineEdit_item_selected(index):
	enemy.time_type = $VBoxContainer/GridContainer/SpawnTimeTypeLineEdit.get_item_id(index)
	if supress_event != true:
			SelectedListManager.apply_values_to_selected_type("time_type", enemy.time_type)

func _on_IsBossGauge_pressed():
	enemy.is_boss_gauge = $VBoxContainer/GridContainer/IsBossGauge.pressed 
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("is_boss_gauge", enemy.is_boss_gauge)

func _on_IsBossBGM_pressed():
	enemy.is_boss_bgm = $VBoxContainer/GridContainer/IsBossBGM.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("is_boss_bgm", enemy.is_boss_bgm)
		
func _on_IsManualSet_pressed():
	enemy.is_manual_set = $VBoxContainer/GridContainer/IsManualSet.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("is_manual_set", enemy.is_manual_set)

func _on_IsAreaBoss_pressed():
	enemy.is_area_boss = $VBoxContainer/GridContainer/IsAreaBoss.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("is_area_boss", enemy.is_area_boss)

func _on_IsBloodEnemy_pressed():
	enemy.is_blood_enemy = $VBoxContainer/GridContainer/BloodOrbsContainer/IsBloodEnemy.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("is_blood_enemy", enemy.is_blood_enemy)

func _on_IsHighOrbEnemy_pressed():
	enemy.is_highorb_enemy = $VBoxContainer/GridContainer/HighOrbsContainer/IsHighOrbEnemy.pressed
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("is_highorb_enemy", enemy.is_highorb_enemy)

func _on_BloodOrbsSpinBox_value_changed(value):
	enemy.blood_orbs = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("blood_orbs", enemy.blood_orbs)

func _on_HighOrbsSpinBox_value_changed(value):
	enemy.high_orbs = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("high_orbs", enemy.high_orbs)

func _on_ExpSpinBox_value_changed(value):
	enemy.experience = int(value)
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("experience", enemy.experience)

func _on_DropsContainer_drops_table_selected(drops_table):
	enemy.drops_table = drops_table
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("drops_table", enemy.drops_table)

func _on_CustomTimeTypeLineEdit_text_entered(text):
	enemy.custom_time = text
	if supress_event != true:
		SelectedListManager.apply_values_to_selected_type("custom_time", enemy.custom_time)
