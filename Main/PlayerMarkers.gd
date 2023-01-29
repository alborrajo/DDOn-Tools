extends Node2D
class_name PlayerMarkers

const PlayerMarkerScene = preload("res://UI/Marker/PlayerMarker.tscn")

onready var ui_node := $"../ui"

func _on_Players_player_joined(player: Player):
	var node := _get_player_node(player)
	if node == null:
		node = PlayerMarkerScene.instance()
		ui_node.connect("map_selected", node, "_on_ui_map_selected")
		ui_node.connect("stage_selected", node, "_on_ui_stage_selected")
		node.set_player(player)
		node._on_ui_map_selected(ui_node.get_selected_map())
		add_child(node)

func _on_Players_player_updated(player: Player):
	var node := _get_player_node(player)
	if node != null:
		node.set_player(player)
		node._on_ui_map_selected(ui_node.get_selected_map())

func _on_Players_player_left(player: Player):
	var node := _get_player_node(player)
	if node != null:
		remove_child(node)
		node.queue_free()


func _get_player_node(player: Player) -> PlayerMarker:
	for n in get_children():
		if n.player.CharacterId == player.CharacterId:
			return n
	return null
