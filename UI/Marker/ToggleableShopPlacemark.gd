extends ToggleablePlacemark
class_name ToggleableShopPlacemark

const FALLBACK_WALLET_TYPE = "$"
const WALLET_TYPES = [
	null,
	"G",
	"R",
	"BO",
	"枚",
	"GG",
	"RP",
	null,
	null,
	"HO",
	"DP",
	"BP",
	"枚",
	null,
	"個",
	"個",
	"個"
]

var stage_id: int setget _set_stage_id
var npc_id: int setget _set_npc_id
var institution_function_id: int setget _set_institution_function_id
var coordinates: Vector3 setget _set_coordinates
var shop: Shop setget _set_shop

func _ready():
	assert(SelectedListManager.connect("item_filter_changed", self, "_on_item_filter_changed") == OK)

func get_display_name() -> String:
	return tr('NPC_NAME_'+String(npc_id))
	
func _set_stage_id(value: int) -> void:
	stage_id = value
	$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(stage_id), coordinates)

func _set_npc_id(value: int) -> void:
	npc_id = value
	$MapControl/ToggleButton.text = get_display_name()

func _set_institution_function_id(value: int) -> void:
	institution_function_id = value
	# TODO: Update icon
	
func _set_coordinates(value: Vector3) -> void:
	coordinates = value
	$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(stage_id), coordinates)

func _set_shop(value: Shop) -> void:
	if value == null:
		return
	if shop != null:
		shop.disconnect("changed", self, "_on_shop_changed")
	shop = value
	assert(shop.connect("changed", self, "_on_shop_changed") == OK)
	_on_shop_changed()
	
func _on_shop_changed() -> void:
	$MapControl/Control/Panel/ShopPlacemark/NpcNameLabel.text = get_display_name()
	$MapControl/Control/Panel/ShopPlacemark/GridContainer/Unk0SpinBox.value = shop.unk0
	$MapControl/Control/Panel/ShopPlacemark/GridContainer/Unk1SpinBox.value = shop.unk1
	$MapControl/Control/Panel/ShopPlacemark/GridContainer2/WalletTypeOptionButton.select(shop.wallet_type)
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.clear()
	var root: TreeItem = $MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.create_item()
	for good in shop.get_goods():
		var tree_item: TreeItem = $MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.create_item(root)
		tree_item.custom_minimum_height = 48
		tree_item.set_text(0, good.item.name)
		tree_item.set_metadata(0, good)
		tree_item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
		tree_item.set_custom_draw(0, self, "_draw_tree_item")

func _draw_tree_item(tree_item: TreeItem, rect: Rect2):
	var good: ShopItem = tree_item.get_metadata(0)
	var color := SelectedListManager.FILTER_NONMATCH_COLOR
	if good.item.matches_filter_text(SelectedListManager.item_filter):
		color = SelectedListManager.FILTER_MATCH_COLOR
	var icon_position := Vector2(rect.position.x + (24 - good.item.icon.get_width()/2), rect.position.y + (rect.size.y/2 - good.item.icon.get_height()/2))
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.draw_texture(good.item.icon, icon_position, color)
	var stock_string := ""
	if not good.is_stock_unlimited:
		stock_string = String(good.stock)+"x "
	var wallet_type := FALLBACK_WALLET_TYPE
	if shop.wallet_type >= 0 and shop.wallet_type < WALLET_TYPES.size() and WALLET_TYPES[shop.wallet_type] != null:
		wallet_type = WALLET_TYPES[shop.wallet_type]
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.draw_string(get_font("font"), rect.position + Vector2(48, rect.size.y/2), "%s%s" % [stock_string, good.item.name], color)
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.draw_string(get_font("font"), rect.position + Vector2(48, rect.size.y/2 + 16), "%s[%d]" % ["★".repeat(good.item.quality_stars), good.item.id], color)
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.draw_string(get_font("font"), rect.position + Vector2(148, rect.size.y/2 + 16), "%d %s" % [good.price, wallet_type], color)

func _on_ItemList_item_rmb_selected(position: Vector2):
	var shop_item: ShopItem = $MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.get_item_at_position(position).get_metadata(0)
	var index := shop.get_goods().find(shop_item)
	assert(index != -1)
	shop.call_deferred("remove_goods", index)

func _on_ItemList_dragged_shop_item(shop_item):
	var index := shop.get_goods().find(shop_item)
	assert(index != -1)
	shop.remove_goods(index)

func _on_ItemList_dropped_shop_item(shop_item):
	shop.add_goods(shop_item)

func _on_item_filter_changed(uppercase_filter_text: String):
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/Tree.update() #rerender
	for good in shop.get_goods():
		if good.item.matches_filter_text(uppercase_filter_text):
			modulate = SelectedListManager.FILTER_MATCH_COLOR
			return
	modulate = SelectedListManager.FILTER_NONMATCH_COLOR
	
