extends Button
class_name Minimize

export (NodePath) var control_to_minimize: NodePath

export var minimize_text := "-"
export var maximize_text := "+"

onready var control_to_minimize_node: Control = get_node(control_to_minimize)

func _ready():
	connect("pressed", self, "_on_pressed")
	_update_label()

func _on_pressed():
	control_to_minimize_node.anchor_bottom = !control_to_minimize_node.anchor_bottom
	_update_label()

func _update_label():
	if control_to_minimize_node.anchor_bottom:
		text = minimize_text
	else:
		text = maximize_text
