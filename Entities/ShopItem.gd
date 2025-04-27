extends Resource
class_name ShopItem

const STORAGE_SECTION_SHOPS := "Shops"
const STORAGE_KEY_SHOP_PRICE_RATE := "ShopPriceRate"
const STORAGE_KEY_SHOP_PRICE_RATE_DEFAULT := 1.5

const DEFAULT_DATE_STRING = "1970-01-01T00:00:00"

var item: Item setget _set_item
var price: int setget _set_price
var is_stock_unlimited: bool setget _set_is_stock_unlimited
var stock: int setget _set_stock
var hide_if_reqs_unmet: bool setget _set_hide_if_reqs_unmet
var sales_period_start: String setget _set_sales_period_start
var sales_period_end: String setget _set_sales_period_end

var _requirements: Array


func _init(_item: Item):
	self.item = _item
	apply_suggested_price()
	self.is_stock_unlimited = true
	self.stock = 0
	self.hide_if_reqs_unmet= 0
	self.sales_period_start = DEFAULT_DATE_STRING
	self.sales_period_end = DEFAULT_DATE_STRING
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

func clone() -> ShopItem:
	var clone: ShopItem = get_script().new(item)
	clone.price = price
	clone.is_stock_unlimited = is_stock_unlimited
	clone.stock = stock
	clone.hide_if_reqs_unmet = hide_if_reqs_unmet
	clone.sales_period_start = sales_period_start
	clone.sales_period_end = sales_period_end
	for req in _requirements:
		clone.add_requirement(req.clone())
	return clone

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
