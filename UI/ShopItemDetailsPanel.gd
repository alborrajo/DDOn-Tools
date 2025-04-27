extends ScrollContainer
class_name ShopItemDetailsPanel

const ShopItemRequirementPanelScene = preload("res://UI/ShopItemRequirementPanel.tscn")

export (NodePath) var title_label: NodePath

var shop_item: ShopItem setget _set_shop_item
var supress_event = true

onready var title_label_node: Label = get_node_or_null(title_label)

func _set_shop_item(i: ShopItem) -> void:
	if shop_item != null and shop_item.is_connected("changed", self, "_on_shop_item_changed"):
		shop_item.disconnect("changed", self, "_on_shop_item_changed")
	
	shop_item = i
	
	if i != null:
		assert(i.connect("changed", self, "_on_shop_item_changed") == OK)
	supress_event = true
	_on_shop_item_changed()
	supress_event = false
	
# TODO: Hide/disable requirements panel if there's multiple shop items selected?

func _on_shop_item_changed():
	if shop_item != null:
		$VBoxContainer2/GridContainer/PriceSpinBox.value = shop_item.price
		$VBoxContainer2/GridContainer/LimitedStockCheckBox.pressed = not shop_item.is_stock_unlimited
		$VBoxContainer2/GridContainer/LimitedStockSpinBox.editable = not shop_item.is_stock_unlimited
		if shop_item.is_stock_unlimited and shop_item.stock == 0:
			shop_item.stock = 10 # better than defaulting to 0
		$VBoxContainer2/GridContainer/LimitedStockSpinBox.value = shop_item.stock
		$VBoxContainer2/GridContainer/HideIfReqsUnmetCheckBox.pressed = shop_item.hide_if_reqs_unmet
		$VBoxContainer2/GridContainer/SalesPeriodContainer/StartLineEdit.text = shop_item.sales_period_start
		$VBoxContainer2/GridContainer/SalesPeriodContainer/EndLineEdit.text = shop_item.sales_period_end
		
		# Requirements
		# Clear previous nodes
		for node in $VBoxContainer2/VBoxContainer/RequirementsContainer.get_children():
			node.queue_free()
		# Add new ones
		var requirements := shop_item.get_requirements()
		for req_idx in requirements.size():
			var requirement: ShopItemRequirement = requirements[req_idx]
			var node: ShopItemRequirementPanel = ShopItemRequirementPanelScene.instance()
			$VBoxContainer2/VBoxContainer/RequirementsContainer.add_child(node)
			node.shop_item_requirement = requirement
			node.connect("requirement_removed", self, "_on_requirement_removed", [req_idx, requirement])
		
		if title_label_node != null:
			var list_count = SelectedListManager.selected_list
			if list_count.size() > 1:
				title_label_node.text = "Selected Nodes: " + str(list_count.size())
			else:
				title_label_node.text = shop_item.item.name


func _on_PriceSpinBox_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("price", value)

func _on_LimitedStockCheckBox_toggled(button_pressed):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("is_stock_unlimited", not button_pressed)

func _on_LimitedStockSpinBox_value_changed(value):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("stock", value)

func _on_HideIfReqsUnmetCheckBox_toggled(button_pressed):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("hide_if_reqs_unmet", button_pressed)

func _on_EndLineEdit_text_changed(new_text):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("sales_period_start", new_text)

func _on_StartLineEdit_text_changed(new_text):
	if supress_event != true:
		SelectedListManager.apply_values_to_selection("sales_period_end", new_text)


func _on_AddRequirementButtonButton_pressed():
	shop_item.add_requirement(ShopItemRequirement.new())

func _on_requirement_removed(index: int, _requirement: ShopItemRequirement):
	shop_item.remove_requirement(index)
