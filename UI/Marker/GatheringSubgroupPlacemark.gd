extends Control
class_name GatheringSubgroupPlacemark

signal subgroup_mouse_entered()
signal subgroup_mouse_exited()

const GATHERING_TYPE_ICONS := [
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_NONE
	"res://resources/items/icon_item100022_ID.png", # OM_GATHER_TREE_LV1
	"res://resources/items/icon_item100023_ID.png", # OM_GATHER_TREE_LV2
	"res://resources/items/icon_item100024_ID.png", # OM_GATHER_TREE_LV3
	"res://resources/items/icon_item100024_ID.png", # OM_GATHER_TREE_LV4, TODO: Different icon
	"res://resources/items/icon_item100019_ID.png", # OM_GATHER_JWL_LV1
	"res://resources/items/icon_item100020_ID.png", # OM_GATHER_JWL_LV2
	"res://resources/items/icon_item100021_ID.png", # OM_GATHER_JWL_LV3
	"res://resources/items/icon_item100025_ID.png", # OM_GATHER_CRST_LV1
	"res://resources/items/icon_item100026_ID.png", # OM_GATHER_CRST_LV2
	"res://resources/items/icon_item100027_ID.png", # OM_GATHER_CRST_LV3
	"res://resources/items/icon_item100027_ID.png", # OM_GATHER_CRST_LV4, TODO: Different icon
	"res://resources/items/icon_item100033_ID.png", # OM_GATHER_KEY_LV1
	"res://resources/items/icon_item100034_ID.png", # OM_GATHER_KEY_LV2
	"res://resources/items/icon_item100034_ID.png", # OM_GATHER_KEY_LV3, TODO: Different icon
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_TREA_IRON
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_DRAGON
	"res://resources/items/icon_item200000_ID.png", # OM_GATHER_CORPSE
	"res://resources/items/icon_item200042_ID.png", # OM_GATHER_SHIP
	"res://resources/items/icon_item200045_ID.png", # OM_GATHER_GRASS
	"res://resources/items/icon_item200047_ID.png", # OM_GATHER_FLOWER
	"res://resources/items/icon_item200049_ID.png", # OM_GATHER_MUSHROOM
	"res://resources/items/icon_item200036_ID.png", # OM_GATHER_CLOTH
	"res://resources/items/icon_item100045_ID.png", # OM_GATHER_BOOK
	"res://resources/items/icon_item200021_ID.png", # OM_GATHER_SAND
	"res://resources/items/icon_item400005_ID.png", # OM_GATHER_BOX
	"res://resources/items/icon_item200082_ID.png", # OM_GATHER_ALCHEMY
	"res://resources/items/icon_item200018_ID.png", # OM_GATHER_WATER
	"res://resources/items/icon_item200054_ID.png", # OM_GATHER_SHELL
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_ANTIQUE
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_TWINKLE
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_TREA_OLD
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_TREA_TREE
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_TREA_SILVER
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_TREA_GOLD
	"res://resources/items/icon_item000000_ID.png", # OM_GATHER_KEY_LV4
	"res://resources/items/icon_item000000_ID.png"  # OM_GATHER_ONE_OFF
]

export (Resource) var gathering_spot: Resource setget _set_gathering_spot

func _set_gathering_spot(value: GatheringSpot) -> void:
	gathering_spot = value
	
	# Update icon
	# TODO: Keep a global cache? Preload all icons?
	$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(value.stage_id), value.coordinates)
	$MapControl/GatheringTypeButton.icon = load(GATHERING_TYPE_ICONS[value.type])
	
	$GatheringSpotPlacemark.gathering_spot = value

func _on_GatheringSpotPlacemark_mouse_entered():
	emit_signal("subgroup_mouse_entered")

func _on_GatheringSpotPlacemark_mouse_exited():
	emit_signal("subgroup_mouse_exited")

func _on_GatheringTypeButton_mouse_entered():
	emit_signal("subgroup_mouse_entered")

func _on_GatheringTypeButton_mouse_exited():
	emit_signal("subgroup_mouse_exited")

func _on_GatheringTypeButton_pressed():
	show_positions()

func _on_GatheringSpotPlacemark_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE and event.pressed:
			hide_positions()

func show_positions() -> void:
	$MapControl/GatheringTypeButton.visible = false
	$GatheringSpotPlacemark.visible = true
	
func hide_positions() -> void:
	$MapControl/GatheringTypeButton.visible = true
	$GatheringSpotPlacemark.visible = false

func _on_GatheringTypeButton_subgroup_selected():
	show_positions()
	$GatheringSpotPlacemark.select_all_placemarks()


