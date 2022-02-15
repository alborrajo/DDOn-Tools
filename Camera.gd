extends Camera2D

export var scroll_speed = 0.1

export (NodePath) var map: NodePath

var _previousPosition: Vector2 = Vector2(0, 0);
var _moveCamera: bool = false;

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		# Drag
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				get_tree().set_input_as_handled();
				_previousPosition = event.position;
				_moveCamera = true;
			else:
				get_tree().set_input_as_handled();
				_moveCamera = false;
			
		# Zoom
		if event.is_pressed():
			match event.button_index:
				BUTTON_WHEEL_UP:
					get_tree().set_input_as_handled()
					zoom *= 1-scroll_speed
				BUTTON_WHEEL_DOWN:
					get_tree().set_input_as_handled();
					zoom *= 1+scroll_speed

func _input(event: InputEvent):
	if event is InputEventMouseMotion && _moveCamera:
		position += (_previousPosition - event.position)*zoom;
		_previousPosition = event.position;
