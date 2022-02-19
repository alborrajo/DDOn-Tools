extends Panel
class_name EnemyDetails

signal enemy_set(enemy)

export (NodePath) var title_label: NodePath

var enemy: Enemy setget _set_enemy

onready var title_label_node: Label = get_node_or_null(title_label)

static func get_instance(tree: SceneTree) -> EnemyDetails:
	return tree.get_nodes_in_group("EnemyDetails")[0]

func _set_enemy(em: Enemy) -> void:
	enemy = em
	if em != null:
		$ScrollContainer/VBoxContainer/GridContainer/NamedEnemyParamsIdLineEdit.value = em.named_enemy_params_id
		$ScrollContainer/VBoxContainer/GridContainer/RaidBossIdLineEdit.value = em.raid_boss_id
		$ScrollContainer/VBoxContainer/GridContainer/ScaleLineEdit.value = em.scale
		$ScrollContainer/VBoxContainer/GridContainer/LevelLineEdit.value = em.lv
		$ScrollContainer/VBoxContainer/GridContainer/HmPresetNoLineEdit.value = em.hm_preset_no
		$ScrollContainer/VBoxContainer/GridContainer/StartThinkTblNoLineEdit.value = em.start_think_tbl_no
		$ScrollContainer/VBoxContainer/GridContainer/RepopNumLineEdit.value = em.repop_num
		$ScrollContainer/VBoxContainer/GridContainer/RepopCountLineEdit.value = em.repop_count
		$ScrollContainer/VBoxContainer/GridContainer/EnemyTargetTypesIdLineEdit.value = em.enemy_target_types_id
		$ScrollContainer/VBoxContainer/GridContainer/MontageFixNoLineEdit.value = em.montage_fix_no
		$ScrollContainer/VBoxContainer/GridContainer/SetTypeLineEdit.value = em.set_type
		$ScrollContainer/VBoxContainer/GridContainer/InfectionTypeLineEdit.value = em.infection_type
		$ScrollContainer/VBoxContainer/GridContainer/IsBossGauge.pressed = em.is_boss_gauge
		$ScrollContainer/VBoxContainer/GridContainer/IsBossBGM.pressed = em.is_boss_bgm
		$ScrollContainer/VBoxContainer/GridContainer/IsManualSet.pressed = em.is_manual_set
		$ScrollContainer/VBoxContainer/GridContainer/IsAreaBoss.pressed = em.is_area_boss
		$ScrollContainer/VBoxContainer/GridContainer/IsBloodEnemy.pressed = em.is_blood_enemy
		$ScrollContainer/VBoxContainer/GridContainer/IsHighOrbEnemy.pressed = em.is_highorb_enemy
		if title_label_node != null:
			title_label_node.text = em.enemy_type.name
	emit_signal("enemy_set", em)


func _on_NamedEnemyParamsIdLineEdit_value_changed(value):
	enemy.named_enemy_params_id = int(value)

func _on_RaidBossIdLineEdit_value_changed(value):
	enemy.raid_boss_id = int(value)

func _on_ScaleLineEdit_value_changed(value):
	enemy.scale = int(value)

func _on_LevelLineEdit_value_changed(value):
	enemy.lv = int(value)

func _on_HmPresetNoLineEdit_value_changed(value):
	enemy.hm_preset_no = int(value)

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

func _on_InfectionTypeLineEdit_value_changed(value):
	enemy.infection_type = int(value)

func _on_IsBossGauge_pressed():
	enemy.is_boss_gauge = $ScrollContainer/VBoxContainer/GridContainer/IsBossGauge.pressed

func _on_IsBossBGM_pressed():
	enemy.is_boss_bgm = $ScrollContainer/VBoxContainer/GridContainer/IsBossBGM.pressed

func _on_IsManualSet_pressed():
	enemy.is_manual_set = $ScrollContainer/VBoxContainer/GridContainer/IsManualSet.pressed

func _on_IsAreaBoss_pressed():
	enemy.is_area_boss = $ScrollContainer/VBoxContainer/GridContainer/IsAreaBoss.pressed

func _on_IsBloodEnemy_pressed():
	enemy.is_blood_enemy = $ScrollContainer/VBoxContainer/GridContainer/IsBloodEnemy.pressed

func _on_IsHighOrbEnemy_pressed():
	enemy.is_highorb_enemy = $ScrollContainer/VBoxContainer/GridContainer/IsHighOrbEnemy.pressed
