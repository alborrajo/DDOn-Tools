extends Camera2D

export var scroll_speed = 0.1
export var touchpad_pan_speed = 10

onready var original_zoom := zoom.x

export (NodePath) var map: NodePath

func _unhandled_input(event):
	# Otherwise, unhandled input doesn't take zoom into account when panning
	if _handle_mouse(event, zoom.x):
		get_tree().set_input_as_handled()

func _on_root_gui_input(event):
	# warning-ignore:return_value_discarded
	_handle_mouse(event)
	
func _handle_mouse(event, multiplier: float = 1) -> bool:
	# Mouse pan
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT) and not get_tree().root.gui_is_dragging():
		global_position -= event.relative * multiplier
		return true
	
	# Mouse zoom
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			BUTTON_WHEEL_UP:
				zoom *= 1-scroll_speed
				return true
			BUTTON_WHEEL_DOWN:
				zoom *= 1+scroll_speed
				return true
	
	# Touchpad pan
	if event is InputEventPanGesture:
		global_position += event.delta*zoom*touchpad_pan_speed
		return true
	
	# Touchpad zoom
	if event is InputEventMagnifyGesture:
		zoom /= event.factor
		return true
		
	return false
