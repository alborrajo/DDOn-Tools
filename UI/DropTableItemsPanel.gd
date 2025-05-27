extends PanelContainer
class_name DropsTableItemsPanel

signal dropped_item(drop_item)

# Drag and drop functions
func can_drop_data(position, data):
	if data is Array:
		for element in data:
			if can_drop_data(position, element):
				return true
	return data is Item
	
func drop_data(position, data):
	if data is Array:
		for element in data:
			drop_data(position, element)
	elif data is Item:
		emit_signal("dropped_item", GatheringItem.new(data)) 
