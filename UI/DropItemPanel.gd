extends VBoxContainer
class_name DropItemPanel

signal drop_item_removed()

var drop_item: GatheringItem = null: set = set_drop_item

func set_drop_item(di: GatheringItem) -> void:
	if drop_item != null and drop_item.is_connected("changed", Callable(self, "_on_drop_item_changed")):
		drop_item.disconnect("changed", Callable(self, "_on_drop_item_changed"))
		
	drop_item = di
	
	if di != null:
		assert(di.connect("changed", Callable(self, "_on_drop_item_changed")) == OK)
		_on_drop_item_changed()
	
func _on_drop_item_changed():
	if drop_item != null:
		$FirstRow/ItemNameLabel.text = drop_item.item.name
		$FirstRow/HFlowContainer/ItemNumSpinBox.value = drop_item.num
		$FirstRow/HFlowContainer/MaxItemNumSpinBox.value = drop_item.max_num
		$SecondRow/GridContainer/DropChanceSpinBox.value = drop_item.drop_chance * 100
		$SecondRow/GridContainer/QualitySpinBox.value = drop_item.quality
		$SecondRow/HiddenCheckBox.button_pressed = drop_item.is_hidden

func _on_ItemNumSpinBox_value_changed(value):
	if drop_item != null:
		drop_item.num = int(value)
		
func _on_MaxItemNumSpinBox_value_changed(value):
	if drop_item != null:
		drop_item.max_num = int(value)

func _on_RemoveButton_pressed():
	if drop_item != null:
		emit_signal("drop_item_removed")

func _on_DropChanceSpinBox_value_changed(value):
	if drop_item != null:
		drop_item.drop_chance = value / 100.0

func _on_QualitySpinBox_value_changed(value):
	if drop_item != null:
		drop_item.quality = int(value)

func _on_HiddenCheckBox_toggled(button_pressed):
	if drop_item != null:
		drop_item.is_hidden = button_pressed
