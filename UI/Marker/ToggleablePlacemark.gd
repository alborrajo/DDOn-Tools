extends Control
class_name ToggleablePlacemark

signal subgroup_mouse_entered()
signal subgroup_mouse_exited()

func _on_Control_mouse_entered():
	move_to_front()
	emit_signal("subgroup_mouse_entered")

func _on_Control_mouse_exited():
	emit_signal("subgroup_mouse_exited")

func _on_ToggleButton_mouse_entered():
	move_to_front()
	emit_signal("subgroup_mouse_entered")

func _on_ToggleButton_mouse_exited():
	emit_signal("subgroup_mouse_exited")
	
func _on_CloseButton_pressed():
	_hide()

func _on_ToggleButton_pressed():
	_show()

func _on_Control_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.is_pressed():
			_hide()

func _show() -> void:
	$MapControl/ToggleButton.visible = false
	$MapControl/Control.visible = true

func _hide() -> void:
	$MapControl/ToggleButton.visible = true
	$MapControl/Control.visible = false
