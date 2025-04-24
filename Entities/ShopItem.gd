extends Resource
class_name ShopItem

const STORAGE_SECTION_SHOPS := "Shops"
const STORAGE_KEY_SHOP_PRICE_RATE := "ShopPriceRate"
const STORAGE_KEY_SHOP_PRICE_RATE_DEFAULT := 1.5

var item: Item setget _set_item
var price: int setget _set_price
var is_stock_unlimited: bool setget _set_is_stock_unlimited
var stock: int setget _set_stock
var hide_if_reqs_unmet: bool setget _set_hide_if_reqs_unmet
var sales_period_start: int setget _set_sales_period_start
var sales_period_end: int setget _set_sales_period_end

var _requirements: Array


func _init(_item: Item):
	self.item = _item
	apply_suggested_price()
	self.is_stock_unlimited = true
	self.stock = 0
	self.hide_if_reqs_unmet= 0
	self.sales_period_start = 0
	self.sales_period_end = 0
	self._requirements = []

func clear_requirements() -> void:
	_requirements.clear()
	
func get_requirements() -> Array:
	return Array(_requirements)
	
func add_requirement(requirement: ShopItemRequirement) -> void:
	_requirements.append(requirement)
	emit_changed()
	
func remove_requirement(index: int) -> void:
	_requirements.remove(index)
	emit_changed()


func _set_item(value):
	item = value
	apply_suggested_price()
	emit_changed()

func _set_price(value):
	price = value
	emit_changed()
	
func _set_is_stock_unlimited(value):
	is_stock_unlimited = value
	emit_changed()
	
func _set_stock(value):
	stock = value
	emit_changed()
	
func _set_hide_if_reqs_unmet(value):
	hide_if_reqs_unmet = value
	emit_changed()
	
func _set_sales_period_start(value):
	sales_period_start = value
	emit_changed()
	
func _set_sales_period_end(value):
	sales_period_end = value
	emit_changed()


func apply_suggested_price() -> void:
	price = item.price * StorageProvider.get_value(STORAGE_SECTION_SHOPS, STORAGE_KEY_SHOP_PRICE_RATE, STORAGE_KEY_SHOP_PRICE_RATE_DEFAULT)
