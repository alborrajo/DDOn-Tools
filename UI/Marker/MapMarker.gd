extends Node2D

class_name MapMarker

var marker : Marker
var sprite : Sprite

func _ready():
	sprite = get_node("Sprite")

func set_marker_json(var json : Dictionary):
	marker = Marker.new(json)
	set_marker(marker)

func set_marker(var p_marker : Marker):
	marker = p_marker
	set_pos_vec(marker.get_map_position())
	if marker.Type == "npc":
		modulate = Color(0, 0, 1)
	if marker.Type == "sce":
		modulate = Color(0, 1, 1)
	if marker.Type == "om":
		modulate = Color(1, 0, 1)
	if marker.Type == "ect":
		modulate = Color(1, 1, 1)

func set_pos_vec(var vec: Vector2):
	set_pos(vec.x, vec.y)

func set_pos(var x, var z):
	position.x = x
	position.y = z
