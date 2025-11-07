extends Control
class_name ToggleablePlacemark

signal subgroup_mouse_entered()
signal subgroup_mouse_exited()

func _on_Control_mouse_entered():
	# Godot 4 migration
	# Node.raise() -> CanvasItem.move_to_front()
	# raise()
	move_to_front()
	emit_signal("subgroup_mouse_entered")

func _on_Control_mouse_exited():
	emit_signal("subgroup_mouse_exited")

func _on_ToggleButton_mouse_entered():
	# Godot 4 migration
	# Node.raise() -> CanvasItem.move_to_front()
	# raise()
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
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.button_pressed:
			_hide()

# Godot 4 migration
# The method "show()" overrides a method from native class "CanvasItem". This won't be called by the engine and may not work as expected.
# func show() -> void:
func _show() -> void:
	$MapControl/ToggleButton.visible = false
	$MapControl/Control.visible = true

# Godot 4 migration
# The method "show()" overrides a method from native class "CanvasItem". This won't be called by the engine and may not work as expected.
# func hide() -> void:
func _hide() -> void:
	$MapControl/ToggleButton.visible = true
	$MapControl/Control.visible = false
