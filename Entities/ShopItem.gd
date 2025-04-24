extends Resource
class_name ShopItem

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
	self.price = 0 # TODO: Use sale price from itemlist.ipa * configurable multiplier
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
