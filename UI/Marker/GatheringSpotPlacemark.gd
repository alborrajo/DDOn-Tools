extends Control
class_name GatheringSpotPlacemark

export (PackedScene) var item_placemark_packed_scene: PackedScene = preload("res://UI/Marker/GatheringItemPlacemark.tscn")

var gathering_spot: GatheringSpot

func _ready() -> void:
	assert(gathering_spot.connect("changed", self, "_on_gathering_spot_changed") == OK)
	_on_gathering_spot_changed()
	
func _on_gathering_spot_changed() -> void:
	# Rebuild children elements
	for child in $"../Container".get_children():
		$"../Container".remove_child(child)
	var gatheringItems = gathering_spot.get_gathering_items()

	for item in gatheringItems:
		var item_placemark: GatheringItemPlacemark = item_placemark_packed_scene.instance()
		item_placemark.gathering_item = item
		assert(item_placemark.connect("placemark_removed", self, "_on_item_removed", [item]) == OK)
		$"../Container".add_child(item_placemark)

func _on_item_removed(item: GatheringItem) -> void:
	var index: int = gathering_spot.get_gathering_items().find(item)
	if index != -1:
		gathering_spot.remove_item(index)
