extends GenericFileMenu
class_name ShopFileMenu

const STORAGE_SECTION_FILE_MENU = "FileMenu"
const STORAGE_KEY_FILE_PATH := "shop_file_path"

func _ready():
	._ready()

func _get_file_path_from_storage() -> String:
	return StorageProvider.get_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH)

func _set_file_path_in_storage() -> void:
	StorageProvider.set_value(STORAGE_SECTION_FILE_MENU, STORAGE_KEY_FILE_PATH, _file_path)

func _do_new_file() -> void:
	SetProvider.clear_shops()

func _do_load_file(file: File) -> void:
	# Read file contents
	var json_parse = JSON.parse(file.get_as_text())
	if json_parse.error != OK:
		print("[load_json_file] Error loading JSON file '" + str(file.get_path()) + "'.")
		print("\tError: ", json_parse.error)
		print("\tError Line: ", json_parse.error_line)
		print("\tError String: ", json_parse.error_string)
		return
	
	# Clear shop state
	SetProvider.clear_shops()

	# Then load it from the file
	for data in json_parse.result:
		var shop_id = data["ShopId"]
		var shop = SetProvider.get_shop(shop_id)
		shop.unk0 = data["Data"]["Unk0"]
		shop.unk1 = data["Data"]["Unk1"]
		shop.wallet_type = data["Data"]["WalletType"]
		for goods_data in data["Data"]["GoodsParamList"]:
			# Ignore Index element
			var item_id = goods_data["ItemId"]
			var item := DataProvider.get_item_by_id(item_id)
			if item == null:
				push_error("Found shop goods entry with an unrecognized item "+ item_id)
				continue
			var shop_item := ShopItem.new(item)
			shop_item.price = goods_data["Price"]
			var stock = goods_data["Stock"]
			if stock == 255:
				shop_item.is_stock_unlimited = true
				shop_item.stock = 0
			else:
				shop_item.is_stock_unlimited = false
				shop_item.stock = stock
			shop_item.hide_if_reqs_unmet = goods_data["HideIfReqsUnmet"]
			shop_item.sales_period_start = goods_data["SalesPeriodStart"]
			shop_item.sales_period_end = goods_data["SalesPeriodEnd"]
			for requirement_data in goods_data["Requirements"]:
				var requirement := ShopItemRequirement.new()
				requirement.index = requirement_data["Index"]
				requirement.condition = requirement_data["Condition"]
				requirement.ignore_requirements = requirement_data["IgnoreRequirements"]
				requirement.hide_requirement_details = requirement_data["HideRequirementDetails"]
				requirement.param1 = requirement_data["Param1"]
				requirement.param2 = requirement_data["Param2"]
				requirement.param3 = requirement_data["Param3"]
				requirement.param4 = requirement_data["Param4"]
				requirement.param5 = requirement_data["Param5"]
				requirement.sales_period_start = requirement_data["SalesPeriodStart"]
				requirement.sales_period_end = requirement_data["SalesPeriodEnd"]
				shop_item.add_requirement(requirement)
			shop.add_goods(shop_item)


func _do_save_file(file: File) -> void:
	var json_data := []
	# Store contents
	for shop in SetProvider.get_all_shops():
		shop = shop as Shop
		var goods_data := []
		var goods = shop.get_goods()
		for index in goods.size():
			var good = goods[index]
			var stock := 255
			if not good.is_stock_unlimited:
				stock = good.stock
			var requirements_data := []
			var requirements = good.get_requirements()
			for req_index in requirements.size():
				var requirement = requirements[req_index]
				requirements_data.append({
					"Index": req_index,
					"Condition": requirement.condition,
					"IgnoreRequirements": requirement.ignore_requirements,
					"HideRequirementDetails": requirement.hide_requirement_details,
					"Param1": requirement.param1,
					"Param2": requirement.param2,
					"Param3": requirement.param3,
					"Param4": requirement.param4,
					"Param5": requirement.param5,
					"SalesPeriodStart": requirement.sales_period_start,
					"SalesPeriodEnd": requirement.sales_period_end,
				})
			goods_data.append({
				"Index": index,
				"ItemId": good.item.id,
				"Price": good.price,
				"Stock": stock,
				"HideIfReqsUnmet": good.hide_if_reqs_unmet,
				"SalesPeriodStart": good.sales_period_start,
				"SalesPeriodEnd": good.sales_period_end,
				"Requirements": requirements_data
			})
			
		var shop_data := {
			"ShopId": shop.id,
			"Data": {
				"Unk0": shop.unk0,
				"Unk1": shop.unk1,
				"WalletType": shop.wallet_type,
				"GoodsParamList": goods_data 
			}
		}
		json_data.append(shop_data)
	
	file.store_string(JSON.print(json_data, "\t"))
