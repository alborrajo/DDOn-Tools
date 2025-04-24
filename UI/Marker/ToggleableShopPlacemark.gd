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
var shop: Shop setget _set_shop

func get_display_name() -> String:
	return tr('NPC_NAME_'+String(npc_id))
	
func _set_stage_id(value: int) -> void:
	stage_id = value
	if shop != null:
		$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(stage_id), shop.coordinates)

func _set_npc_id(value: int) -> void:
	npc_id = value
	$MapControl/ToggleButton.text = get_display_name()

func _set_shop(value: Shop) -> void:
	if value == null:
		return
		
	if shop != null:
		shop.disconnect("changed", self, "_on_shop_changed")

	shop = value
	assert(shop.connect("changed", self, "_on_shop_changed") == OK)
	_on_shop_changed()
	
	# Update icon and position
	$MapControl.set_ddon_world_position(DataProvider.stage_id_to_stage_no(stage_id), value.coordinates)
	
func _on_shop_changed() -> void:
	$MapControl/Control/Panel/ShopPlacemark/NpcNameLabel.text = get_display_name()
	$MapControl/Control/Panel/ShopPlacemark/GridContainer/Unk0SpinBox.value = shop.unk0
	$MapControl/Control/Panel/ShopPlacemark/GridContainer/Unk1SpinBox.value = shop.unk1
	$MapControl/Control/Panel/ShopPlacemark/GridContainer2/WalletTypeOptionButton.select(shop.wallet_type)
	$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/ItemList.clear()
	for good in shop.get_goods():
		good = good as ShopItem
		var stock_string := ""
		if not good.is_stock_unlimited:
			stock_string = String(good.stock)+" "
		var wallet_type := FALLBACK_WALLET_TYPE
		if shop.wallet_type >= 0 and shop.wallet_type < WALLET_TYPES.size() and WALLET_TYPES[shop.wallet_type] != null:
			wallet_type = WALLET_TYPES[shop.wallet_type]
		var text := "%s%s\n%d %s" % [stock_string, good.item.name, good.price, wallet_type]
		$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/ItemList.add_item(text, good.item.icon)
		var last_added_item_index: int = $MapControl/Control/Panel/ShopPlacemark/ScrollContainer/ItemList.get_item_count()-1
		$MapControl/Control/Panel/ShopPlacemark/ScrollContainer/ItemList.set_item_metadata(last_added_item_index, good)

func _on_ItemList_item_rmb_selected(index, _at_position):
	shop.remove_goods(index)

func _on_ItemList_dragged_shop_item(index):
	shop.remove_goods(index)

func _on_ItemList_dropped_shop_item(shop_item):
	shop.add_goods(shop_item)
