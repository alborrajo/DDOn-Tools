extends Control
class_name ToggleablePlacemark

signal subgroup_mouse_entered()
signal subgroup_mouse_exited()

func _on_Control_mouse_entered():
	raise()
	emit_signal("subgroup_mouse_entered")

func _on_Control_mouse_exited():
	emit_signal("subgroup_mouse_exited")

func _on_ToggleButton_mouse_entered():
	raise()
	emit_signal("subgroup_mouse_entered")

func _on_ToggleButton_mouse_exited():
	emit_signal("subgroup_mouse_exited")
	
func _on_CloseButton_pressed():
	hide()

func _on_ToggleButton_pressed():
	show()

func _on_Control_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE and event.pressed:
			hide()

func show() -> void:
	$MapControl/ToggleButton.visible = false
	$MapControl/Control.visible = true
	
func hide() -> void:
	$MapControl/ToggleButton.visible = true
	$MapControl/Control.visible = false

func _on_ToggleButton_subgroup_selected():
	show()
	# Subclasses must implement selection
