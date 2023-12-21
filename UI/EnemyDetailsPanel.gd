extends ScrollContainer
class_name EnemyDetailsPanel

const COLOR_BLOOD_ORB = Color.violet
const COLOR_HIGH_ORB = Color.orangered
const COLOR_DEFAULT = Color.white

export (NodePath) var title_label: NodePath

var enemy: Enemy setget _set_enemy

onready var title_label_node: Label = get_node_or_null(title_label)

func _set_enemy(em: Enemy) -> void:
	if enemy != null and enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
	
	enemy = em
	
	if em != null:
		em.connect("changed", self, "_on_enemy_changed")
	
	_on_enemy_changed()
	
func _on_enemy_changed():
	if enemy != null:
		$VBoxContainer/NamedEnemyParamsIdOptionButton.select($VBoxContainer/NamedEnemyParamsIdOptionButton.get_item_index(enemy.named_enemy_params_id))
		$VBoxContainer/GridContainer/RaidBossIdLineEdit.value = enemy.raid_boss_id
		$VBoxContainer/GridContainer/ScaleLineEdit.value = enemy.scale
		$VBoxContainer/GridContainer/LevelLineEdit.value = enemy.lv
		$VBoxContainer/GridContainer/HmPresetNoOptionButton.select($VBoxContainer/GridContainer/HmPresetNoOptionButton.get_item_index(enemy.hm_preset_no))
		$VBoxContainer/GridContainer/StartThinkTblNoLineEdit.value = enemy.start_think_tbl_no
		$VBoxContainer/GridContainer/RepopNumLineEdit.value = enemy.repop_num
		$VBoxContainer/GridContainer/RepopCountLineEdit.value = enemy.repop_count
		$VBoxContainer/GridContainer/EnemyTargetTypesIdLineEdit.value = enemy.enemy_target_types_id
		$VBoxContainer/GridContainer/MontageFixNoLineEdit.value = enemy.montage_fix_no
		$VBoxContainer/GridContainer/SetTypeLineEdit.value = enemy.set_type
		$VBoxContainer/GridContainer/InfectionTypeLineEdit.select($VBoxContainer/GridContainer/InfectionTypeLineEdit.get_item_index(enemy.infection_type))
		$VBoxContainer/GridContainer/IsBossGauge.pressed = enemy.is_boss_gauge
		$VBoxContainer/GridContainer/IsBossBGM.pressed = enemy.is_boss_bgm
		$VBoxContainer/GridContainer/IsManualSet.pressed = enemy.is_manual_set
		$VBoxContainer/GridContainer/IsAreaBoss.pressed = enemy.is_area_boss
		$VBoxContainer/GridContainer/IsBloodEnemy.pressed = enemy.is_blood_enemy
		$VBoxContainer/GridContainer/IsHighOrbEnemy.pressed = enemy.is_highorb_enemy
		
		# Duplicate code from EnemyPlacemark, where a similar thing is done.
		# TODO: thonk
		if title_label_node != null:
			title_label_node.text = enemy.get_display_name()
			
			if enemy.is_blood_enemy:
				title_label_node.modulate = COLOR_BLOOD_ORB
			elif enemy.is_highorb_enemy:
				title_label_node.modulate = COLOR_HIGH_ORB
			else: 
				title_label_node.modulate = COLOR_DEFAULT


func _on_NamedEnemyParamsIdOptionButton_item_selected(index):
	enemy.named_enemy_params_id = $VBoxContainer/NamedEnemyParamsIdOptionButton.get_item_id(index)

func _on_RaidBossIdLineEdit_value_changed(value):
	enemy.raid_boss_id = int(value)

func _on_ScaleLineEdit_value_changed(value):
	enemy.scale = int(value)

func _on_LevelLineEdit_value_changed(value):
	enemy.lv = int(value)

func _on_HmPresetNoLineEdit_item_selected(index):
	enemy.hm_preset_no = $VBoxContainer/GridContainer/HmPresetNoOptionButton.get_item_id(index)

func _on_StartThinkTblNoLineEdit_value_changed(value):
	enemy.start_think_tbl_no = int(value)

func _on_RepopNumLineEdit_value_changed(value):
	enemy.repop_num = int(value)

func _on_RepopCountLineEdit_value_changed(value):
	enemy.repop_count = int(value)

func _on_EnemyTargetTypesIdLineEdit_value_changed(value):
	enemy.enemy_target_types_id = int(value)

func _on_MontageFixNoLineEdit_value_changed(value):
	enemy.montage_fix_no = int(value)

func _on_SetTypeLineEdit_value_changed(value):
	enemy.set_type = int(value)

func _on_InfectionTypeLineEdit_item_selected(index):
	enemy.infection_type = $VBoxContainer/GridContainer/InfectionTypeLineEdit.get_item_id(index)

func _on_IsBossGauge_pressed():
	enemy.is_boss_gauge = $VBoxContainer/GridContainer/IsBossGauge.pressed

func _on_IsBossBGM_pressed():
	enemy.is_boss_bgm = $VBoxContainer/GridContainer/IsBossBGM.pressed

func _on_IsManualSet_pressed():
	enemy.is_manual_set = $VBoxContainer/GridContainer/IsManualSet.pressed

func _on_IsAreaBoss_pressed():
	enemy.is_area_boss = $VBoxContainer/GridContainer/IsAreaBoss.pressed

func _on_IsBloodEnemy_pressed():
	enemy.is_blood_enemy = $VBoxContainer/GridContainer/IsBloodEnemy.pressed

func _on_IsHighOrbEnemy_pressed():
	enemy.is_highorb_enemy = $VBoxContainer/GridContainer/IsHighOrbEnemy.pressed
