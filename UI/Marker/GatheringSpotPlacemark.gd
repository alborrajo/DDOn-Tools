extends GenericSetPlacemark
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

	for index in gatheringItems.size():
		var item: GatheringItem = gatheringItems[index]
		var item_placemark: GatheringItemPlacemark = item_placemark_packed_scene.instance()
		item_placemark.item = item
		assert(item_placemark.connect("placemark_removed", self, "_on_item_removed", [index]) == OK)
		$"../Container".add_child(item_placemark)


func _on_item_removed(index: int) -> void:
	gathering_spot.remove_item(index)


func select_all_placemarks():
	for gathering_item in gathering_spot.get_gathering_items():
		SelectedListManager.add_to_selection(gathering_item)
