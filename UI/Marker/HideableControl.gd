extends Control
class_name HideableControl

const HIDDEN_ALPHA_MULTIPLIER = 0.25

onready var _original_mouse_filter := mouse_filter
onready var _original_modulate := modulate

func _ready():
	assert(SelectedListManager.connect("set_revealed_hidden", self, "unhide_control") == OK)

func hide_control():
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	modulate = Color(_original_modulate.r, _original_modulate.g, _original_modulate.b, _original_modulate.a * HIDDEN_ALPHA_MULTIPLIER)

func unhide_control():
	propagate_call("set_mouse_filter", [_original_mouse_filter])
	modulate = _original_modulate
