extends GenericSetPlacemark
class_name GatheringSpotPlacemark

export (PackedScene) var item_placemark_packed_scene: PackedScene = preload("res://UI/Marker/GatheringItemPlacemark.tscn")

export (Resource) var gathering_spot: Resource

onready var _gathering_spot := gathering_spot as GatheringSpot


func _ready() -> void:
	assert(_gathering_spot.connect("changed", self, "_on_gathering_spot_changed") == OK)
	_on_gathering_spot_changed()
	
func _on_gathering_spot_changed() -> void:
	# Rebuild children elements
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
	var gatheringItems = _gathering_spot.get_gathering_items()

	for index in gatheringItems.size():
		var item: GatheringItem = gatheringItems[index]
		var item_placemark: GatheringItemPlacemark = item_placemark_packed_scene.instance()
		item_placemark.item = item
		assert(item_placemark.connect("placemark_removed", self, "_on_item_removed", [index]) == OK)
		$VBoxContainer.add_child(item_placemark)


func _on_item_removed(index: int) -> void:
	_gathering_spot.remove_item(index)


func add_item(item: GatheringItem) -> void:
	_gathering_spot.add_item(item)

func clear_items() -> void:
	_gathering_spot.clear_items()

func get_items() -> Array:
	return _gathering_spot.get_items()

# Drag and drop functions
func can_drop_data(_position, data):
	return data is Item or data is GatheringItem
	
func drop_data(_position, data):
	if data is GatheringItem:
		add_item(data)
	elif data is Item:
		add_item(GatheringItem.new(data))
