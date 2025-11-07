extends PanelContainer
class_name DropsTableItemsPanel

signal dropped_item(drop_item)

# Drag and drop functions
func _can_drop_data(at_position, data):
	if data is Array:
		for element in data:
			if _can_drop_data(at_position, element):
				return true
	return data is Item
	
func _drop_data(at_position, data):
	if data is Array:
		for element in data:
			_drop_data(at_position, element)
	elif data is Item:
		emit_signal("dropped_item", GatheringItem.new(data)) 
