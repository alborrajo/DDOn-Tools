extends Camera2D

@export var scroll_speed = 0.1
@export var touchpad_pan_speed = 10

@onready var original_zoom := zoom.x

@export var map: NodePath

func _unhandled_input(event):
	# Otherwise, unhandled input doesn't take zoom into account when panning
	if _handle_mouse(event):
		get_viewport().set_input_as_handled()

func _on_root_gui_input(event):
	# warning-ignore:return_value_discarded
	_handle_mouse(event)
	
func _handle_mouse(event) -> bool:
	# Mouse pan
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not get_tree().root.gui_is_dragging():
		global_position -= event.relative/zoom
		return true
	
	# Mouse zoom
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				zoom *= 1+scroll_speed
				return true
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom *= 1-scroll_speed
				return true
	
	# Touchpad pan
	if event is InputEventPanGesture:
		global_position += event.delta*touchpad_pan_speed*DisplayServer.screen_get_scale()/zoom
		return true
	
	# Touchpad zoom
	if event is InputEventMagnifyGesture:
		zoom *= event.factor
		return true
		
	return false
