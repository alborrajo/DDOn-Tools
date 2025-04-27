extends PanelContainer
class_name ShopItemRequirementPanel

signal requirement_removed()

var shop_item_requirement: ShopItemRequirement setget _set_shop_item_requirement

func _ready() -> void:
	_build_enemy_category_option_button()

func _build_enemy_category_option_button() -> void:
	for enemy_type in DataProvider.enemy_list:
		var category_string := "ENEMY_CATEGORY_"+String(enemy_type.category)
		$VBoxContainer/DetailsContainer/DefeatEnemiesContainer/HFlowContainer/Param3OptionButton.add_item(category_string, enemy_type.category)
		$VBoxContainer/DetailsContainer/DefeatEnemiesLevelContainer/HFlowContainer/Param3OptionButton.add_item(category_string, enemy_type.category)

func _set_shop_item_requirement(value: ShopItemRequirement) -> void:
	if shop_item_requirement != null and shop_item_requirement.is_connected("changed", self, "_on_shop_item_requirement_changed"):
		shop_item_requirement.disconnect("changed", self, "_on_shop_item_requirement_changed")
	
	shop_item_requirement = value
	
	assert(shop_item_requirement.connect("changed", self, "_on_shop_item_requirement_changed") == OK)
	_on_shop_item_requirement_changed()
	
func _on_shop_item_requirement_changed() -> void:
	if shop_item_requirement != null:
		$VBoxContainer/HBoxContainer/ConditionOptionButton.select($VBoxContainer/HBoxContainer/ConditionOptionButton.get_item_index(shop_item_requirement.condition))
		$VBoxContainer/DetailsContainer/IgnoreReqsCheckBox.pressed = shop_item_requirement.ignore_requirements
		$VBoxContainer/DetailsContainer/HideReqsCheckBox.pressed = shop_item_requirement.hide_requirement_details
		$VBoxContainer/DetailsContainer/GridContainer/SalesPeriodContainer/StartLineEdit.text = shop_item_requirement.sales_period_start
		$VBoxContainer/DetailsContainer/GridContainer/SalesPeriodContainer/EndLineEdit.text = shop_item_requirement.sales_period_end
		
		# Condition nodes
		$VBoxContainer/DetailsContainer/ClearWithRankContainer.visible = false
		$VBoxContainer/DetailsContainer/DefeatEnemiesContainer.visible = false
		$VBoxContainer/DetailsContainer/WarMissionPointsContainer.visible = false
		$VBoxContainer/DetailsContainer/UnlockPlayPointsContainer.visible = false
		$VBoxContainer/DetailsContainer/DefeatEnemiesLevelContainer.visible = false
		
		if shop_item_requirement.condition == ShopItemRequirement.REQUIREMENT_CONDITION_CLEAR_WITH_RANK:
			$VBoxContainer/DetailsContainer/ClearWithRankContainer.visible = true
			$VBoxContainer/DetailsContainer/ClearWithRankContainer/HFlowContainer/Param1SpinBox.value = shop_item_requirement.param1
			$VBoxContainer/DetailsContainer/ClearWithRankContainer/HFlowContainer/Param2SpinBox.value = shop_item_requirement.param2
		elif shop_item_requirement.condition == ShopItemRequirement.REQUIREMENT_CONDITION_DEFEAT_ENEMIES:
			$VBoxContainer/DetailsContainer/DefeatEnemiesContainer.visible = true
			$VBoxContainer/DetailsContainer/DefeatEnemiesContainer/HFlowContainer/Param1SpinBox.value = shop_item_requirement.param1
			$VBoxContainer/DetailsContainer/DefeatEnemiesContainer/HFlowContainer/Param3OptionButton.select($VBoxContainer/DetailsContainer/DefeatEnemiesContainer/HFlowContainer/Param3OptionButton.get_item_index(shop_item_requirement.param3))
		elif shop_item_requirement.condition == ShopItemRequirement.REQUIREMENT_CONDITION_WAR_MISSION_POINTS:
			$VBoxContainer/DetailsContainer/WarMissionPointsContainer.visible = true
			$VBoxContainer/DetailsContainer/WarMissionPointsContainer/HFlowContainer/Param1SpinBox.value = shop_item_requirement.param1
		elif shop_item_requirement.condition == ShopItemRequirement.REQUIREMENT_CONDITION_UNLOCK_PLAY_POINTS:
			$VBoxContainer/DetailsContainer/UnlockPlayPointsContainer.visible = true
		elif shop_item_requirement.condition == ShopItemRequirement.REQUIREMENT_CONDITION_DEFEAT_ENEMIESLEVEL:
			$VBoxContainer/DetailsContainer/DefeatEnemiesLevelContainer.visible = true
			$VBoxContainer/DetailsContainer/DefeatEnemiesLevelContainer/HFlowContainer/Param1SpinBox.value = shop_item_requirement.param1
			$VBoxContainer/DetailsContainer/DefeatEnemiesLevelContainer/HFlowContainer/Param2SpinBox.value = shop_item_requirement.param2
			$VBoxContainer/DetailsContainer/DefeatEnemiesLevelContainer/HFlowContainer/Param3OptionButton.select($VBoxContainer/DetailsContainer/DefeatEnemiesContainer/HFlowContainer/Param3OptionButton.get_item_index(shop_item_requirement.param3))

func _on_RemoveButton_pressed():
	emit_signal("requirement_removed")

func _on_ConditionOptionButton_item_selected(index):
	shop_item_requirement.condition = $VBoxContainer/HBoxContainer/ConditionOptionButton.get_item_id(index)

func _on_IgnoreReqsCheckBox_toggled(button_pressed):
	shop_item_requirement.ignore_requirements = button_pressed

func _on_HideReqsCheckBox_toggled(button_pressed):
	shop_item_requirement.hide_requirement_details = button_pressed

func _on_StartLineEdit_text_changed(new_text):
	shop_item_requirement.sales_period_start = new_text

func _on_EndLineEdit_text_changed(new_text):
	shop_item_requirement.sales_period_end = new_text


# Clear with rank and war mission points
func _on_Param1SpinBox_value_changed(value):
	shop_item_requirement.param1 = value

# Clear with rank, defeat enemies, and defeat enemies level
func _on_Param2SpinBox_value_changed(value):
	shop_item_requirement.param2 = value
	
# Defeat enemies and defeat enemies level
func _on_Param3OptionButton_item_selected(index):
	shop_item_requirement.param3 = $VBoxContainer/DetailsContainer/DefeatEnemiesContainer/HFlowContainer/Param3OptionButton.get_item_id(index)
