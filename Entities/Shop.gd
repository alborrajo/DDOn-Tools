extends Resource
class_name Shop

# Client data, loaded in Main.gd from bundled shops.json file extracted from the client
var id: int

# Server data, loaded in ShopFileMenu.gd from user-provided Shop.json file used in the server
export var unk0: int setget _set_unk0
export var unk1: int setget _set_unk1
export var wallet_type: int setget _set_wallet_type

# TODO: Move invariant client data to a different class?

var _goods_param_list: Array = []

func _init(_id: int):
	self.id = _id

func clear_goods() -> void:
	_goods_param_list.clear()
	emit_changed()
	
func get_goods() -> Array:
	return Array(_goods_param_list)
	
func add_goods(shop_item: ShopItem) -> void:
	_goods_param_list.append(shop_item)
	emit_changed()
	
func add_goods_at(index: int, shop_item: ShopItem) -> void:
	_goods_param_list.insert(index, shop_item)
	emit_changed()
	
func remove_goods(index: int) -> void:
	_goods_param_list.remove(index)
	emit_changed()

func _set_unk0(v: int) -> void:
	unk0 = v
	emit_changed()
	
func _set_unk1(v: int) -> void:
	unk1 = v
	emit_changed()

func _set_wallet_type(new_wallet_type: int) -> void:
	wallet_type = new_wallet_type
	emit_changed()
