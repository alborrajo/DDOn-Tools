extends Panel
class_name DetailsPanel

signal showing_details_of(obj)

static func get_instance(tree: SceneTree) -> DetailsPanel:
	return tree.get_nodes_in_group("DetailsPanel")[0]
	
func hide_details():
	for child in self.get_children():
		child.visible = false
	
func show_details_of(obj):
	hide_details()
	if obj == null:
		pass
	elif obj is Enemy:
		$EnemyDetailsPanel.enemy = obj
		$EnemyDetailsPanel.visible = true
		emit_signal("showing_details_of", obj)
	elif obj is GatheringItem:
		$ItemDetailsPanel.item = obj
		$ItemDetailsPanel.visible = true
		emit_signal("showing_details_of", obj)
	else:
		push_error("Attempted to show the details of an unrecognized object")
