extends Node2D

class_name MapMarker

signal hover

var marker : Marker
var sprite : Sprite

func _ready():
	sprite = get_node("sprite")

func set_marker_json(var json : Dictionary):
	marker = Marker.new(json)
	set_marker(marker)

func set_marker(var p_marker : Marker):
	marker = p_marker
	set_pos_vec(marker.get_map_position())
	if marker.Type == "npc":
		modulate = Color.red
	if marker.Type == "sce":
		modulate = Color.green
	if marker.Type == "om":
		modulate = Color.blue
	if marker.Type == "ect":
		modulate = Color.yellow

func set_pos_vec(var vec: Vector2):
	set_pos(vec.x, vec.y)

func set_pos(var x, var z):
	position.x = x
	position.y = z

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos : Vector2 = get_local_mouse_position();
		var map_sprite_pos : Vector2 = sprite.get_local_mouse_position();
		if sprite.get_rect().has_point(map_sprite_pos):
			emit_signal("hover", self)
