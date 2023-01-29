extends Camera2D

export var scroll_speed = 0.1
export var touchpad_pan_speed = 10

onready var original_zoom := zoom.x

export (NodePath) var map: NodePath

func _on_root_gui_input(event):
	# Mouse pan
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT) and not get_tree().root.gui_is_dragging():
		position -= event.relative
	
	# Mouse zoom
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			BUTTON_WHEEL_UP:
				zoom *= 1-scroll_speed
			BUTTON_WHEEL_DOWN:
				zoom *= 1+scroll_speed
	
	# Touchpad pan
	if event is InputEventPanGesture:
		position += event.delta*zoom*touchpad_pan_speed
	
	# Touchpad zoom
	if event is InputEventMagnifyGesture:
		zoom /= event.factor
