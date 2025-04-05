extends Control
class_name GatheringSubgroupPlacemark

signal subgroup_mouse_entered()
signal subgroup_mouse_exited()

const GATHERING_TYPE_ICONS := [
	null, # OM_GATHER_NONE
	"res://resources/items/ii000449/icon_item100022_ID.png", # OM_GATHER_TREE_LV1
	"res://resources/items/ii000450/icon_item100023_ID.png", # OM_GATHER_TREE_LV2
	"res://resources/items/ii000451/icon_item100024_ID.png", # OM_GATHER_TREE_LV3
	"res://resources/items/ii000451/icon_item100024_ID.png", # OM_GATHER_TREE_LV4, TODO: Different icon
	"res://resources/items/ii000446/icon_item100019_ID.png", # OM_GATHER_JWL_LV1
	"res://resources/items/ii000447/icon_item100020_ID.png", # OM_GATHER_JWL_LV2
	"res://resources/items/ii000448/icon_item100021_ID.png", # OM_GATHER_JWL_LV3
	"res://resources/items/ii000452/icon_item100025_ID.png", # OM_GATHER_CRST_LV1
	"res://resources/items/ii000453/icon_item100026_ID.png", # OM_GATHER_CRST_LV2
	"res://resources/items/ii000454/icon_item100027_ID.png", # OM_GATHER_CRST_LV3
	"res://resources/items/ii000454/icon_item100027_ID.png", # OM_GATHER_CRST_LV4, TODO: Different icon
	"res://resources/items/ii000460/icon_item100033_ID.png", # OM_GATHER_KEY_LV1
	"res://resources/items/ii000461/icon_item100034_ID.png", # OM_GATHER_KEY_LV2
	"res://resources/items/ii000461/icon_item100034_ID.png", # OM_GATHER_KEY_LV3, TODO: Different icon
	null, # OM_GATHER_TREA_IRON
	null, # OM_GATHER_DRAGON
	"res://resources/items/ii000463/icon_item200000_ID.png", # OM_GATHER_CORPSE
	"res://resources/items/ii000505/icon_item200042_ID.png", # OM_GATHER_SHIP
	"res://resources/items/ii000508/icon_item200045_ID.png", # OM_GATHER_GRASS
	"res://resources/items/ii000510/icon_item200047_ID.png", # OM_GATHER_FLOWER
	"res://resources/items/ii000512/icon_item200049_ID.png", # OM_GATHER_MUSHROOM
	"res://resources/items/ii000499/icon_item200036_ID.png", # OM_GATHER_CLOTH
	"res://resources/items/ii002604/icon_item100045_ID.png", # OM_GATHER_BOOK
	"res://resources/items/ii000484/icon_item200021_ID.png", # OM_GATHER_SAND
	"res://resources/items/ii000536/icon_item400005_ID.png", # OM_GATHER_BOX
	"res://resources/items/ii001275/icon_item200082_ID.png", # OM_GATHER_ALCHEMY
	"res://resources/items/ii000481/icon_item200018_ID.png", # OM_GATHER_WATER
	"res://resources/items/ii000517/icon_item200054_ID.png", # OM_GATHER_SHELL
	null, # OM_GATHER_ANTIQUE
	"res://resources/items/ii001991/icon_item200144_ID.png", # OM_GATHER_TWINKLE
	"res://resources/items/ii000423/icon_item000010_ID.png", # OM_GATHER_TREA_OLD (Old chest)
	"res://resources/items/ii000423/icon_item000010_ID.png", # OM_GATHER_TREA_TREE (Wooden chest)
	null, # OM_GATHER_TREA_SILVER
	null, # OM_GATHER_TREA_GOLD
	null, # OM_GATHER_KEY_LV4
	"res://resources/items/ii002093/icon_item200145_ID.png"  # OM_GATHER_ONE_OFF (Season 2 red glows)
]

const OM_UNIT_ID_ICONS = {
	523907: null,
	523908: null,
	520070: "res://resources/items/ii000536/icon_item400005_ID.png", # Box with meat
	520071: null,
	520080: null,
	520081: null,
	513050: null,
	513051: "res://resources/items/ii000423/icon_item000010_ID.png", # Wooden chest
	520090: null,
	513052: "res://resources/items/ii000423/icon_item000010_ID.png", # Old chest
	513054: "res://resources/items/ii000423/icon_item000010_ID.png", # Glowing stone chest on top of BBI Sage Tower Ruins
	513053: null,
	513056: null,
	513055: null,
	520100: null,
	513060: null,
	513061: null,
	520110: null,
	520111: "res://resources/items/ii001275/icon_item200082_ID.png", # Pile of gold and alchemy
	522552: null,
	520000: null, # OM_ID_GATHERABLE_GRASS
	520001: null, # OM_ID_GATHERABLE_GRASS_VASE
	520002: null, # OM_ID_GATHERABLE_GRASS_TREE
	520003: null, # OM_ID_GATHERABLE_GRASS_POLE_OR_ROCK
	520004: null, # OM_ID_GATHERABLE_GRASS_ROCK
	520010: null,
	520011: null,
	520012: null,
	520020: null,
	520021: null,
	520022: null,
	520023: "res://resources/items/ii000512/icon_item200049_ID.png", # Mushrooms
	520024: null,
	520030: null,
	520031: null,
	520160: null,
	520032: null,
	520162: null,
	520033: null,
	520161: null,
	520163: null,
	523240: null,
	520041: null, # OM_ID_GATHERABLE_OLD_BOOK_WITH_FEATHER
	520170: null, # OM_ID_GATHER_TWINKLE
	520171: "res://resources/items/ii002093/icon_item200145_ID.png", # Red twinkles
	513130: null, # OM_ID_BBM_SEALED_TREASURE_BOX_ORANGE
	513133: null, # OM_ID_BBM_SEALED_TREASURE_BOX_BLUE
	513134: null, # OM_ID_SEALED_TREASURE_BOX_BLUE
	523241: null,
	523242: null,
	520050: null,
	520051: null,
	520052: null,
	520060: null
}

const UNKNOWN_ITEM_ICON = "res://resources/items/ii000000/icon_item000000_ID.png"

export (Resource) var gathering_spot: Resource setget _set_gathering_spot

func _set_gathering_spot(value: GatheringSpot) -> void:
	gathering_spot = value
	
	# Update icon and position
	$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(value.stage_id), value.coordinates)
	if GATHERING_TYPE_ICONS[value.type] != null:
		$MapControl/GatheringTypeButton.icon = load(GATHERING_TYPE_ICONS[value.type])
	elif OM_UNIT_ID_ICONS.get(value.unit_id) != null:
		$MapControl/GatheringTypeButton.icon = load(OM_UNIT_ID_ICONS[value.unit_id])
	else:
		$MapControl/GatheringTypeButton.icon = load(UNKNOWN_ITEM_ICON)
	
	$GatheringSpotPlacemark.gathering_spot = value

func _on_GatheringSpotPlacemark_mouse_entered():
	emit_signal("subgroup_mouse_entered")

func _on_GatheringSpotPlacemark_mouse_exited():
	emit_signal("subgroup_mouse_exited")

func _on_GatheringTypeButton_mouse_entered():
	emit_signal("subgroup_mouse_entered")

func _on_GatheringTypeButton_mouse_exited():
	emit_signal("subgroup_mouse_exited")
	
func _on_GatheringSpotPlacemark_closed():
	hide_positions()

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
