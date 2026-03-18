extends Node

signal drops_tables_updated()
# Godot 4 migration
# signals and vars can't have the same name
# signal selected_day_night()
signal s_selected_day_night()

var _drops_tables := [] # TODO: Maybe use a dictionary instead
var _enemy_sets := []
# Godot 4 migration
# commented out as unused
# var _enemy_set_templates := []
var _gathering_spots := []
var _shops := []
var selected_day_night = 0

func _ready():
	for stage_no in DataProvider.enemy_sets.keys():
		for enemy_set in DataProvider.enemy_sets[stage_no]:
			var stage_id := DataProvider.stage_no_to_stage_id(int(stage_no))
			var layer_no := 0
			var group_no := int(enemy_set["GroupNo"])
			var subgroup_no := -1#int(enemy_set["SubGroupNo"])
			var enemy_set_instance := EnemySet.new(stage_id, layer_no, group_no)
			var positions = []
			for position_index in enemy_set["Positions"].size():
				var position = enemy_set["Positions"][position_index]
				var pos := Vector3(position["x"], position["y"], position["z"])
				positions.append(pos)
			if subgroup_no == -1:
				enemy_set_instance.subgroup_position_template = positions
			else:
				assert(enemy_set_instance.get_subgroup_or_create_with_positions(subgroup_no, positions) != null)
			_enemy_sets.append(enemy_set_instance)

func select_day_night_func(index):
	# Emit a custom signal with the selected index
	emit_signal("s_selected_day_night", index)
	selected_day_night = index

func clear_drops_tables() -> void:
	_drops_tables.clear()
	emit_signal("drops_tables_updated")

func remove_drops_table(drops_table_id: int) -> DropsTable:
	for idx in _drops_tables.size():
		var table: DropsTable = _drops_tables[idx]
		if table.id == drops_table_id:
			_drops_tables.remove_at(idx)
			emit_signal("drops_tables_updated")
			return table
	return null

func get_drops_table(drops_table_id: int) -> DropsTable:
	for table in _drops_tables:
		if table.id == drops_table_id:
			return table

	var table := DropsTable.new(drops_table_id)
	_drops_tables.append(table)
	emit_signal("drops_tables_updated")
	return table

func get_all_drops_tables() -> Array:
	return Array(_drops_tables)


func clear_enemy_sets() -> void:
	# Godot 4 migration
	# set is used to declare setter so we shouldn't use it for var names
	for enemy_set in _enemy_sets:
		enemy_set.clear_enemies()

func get_enemy_set(stage_id: int, layer_no: int, group_id: int) -> EnemySet:
	# Inefficient af
	for enemy_set in _enemy_sets:
		if enemy_set.stage_id == stage_id and enemy_set.layer_no == layer_no and enemy_set.group_id == group_id:
			return enemy_set
		
	return null

func get_all_enemy_sets() -> Array:
	return Array(_enemy_sets)
	
func apply_suggested_values_for_all_enemies() -> void:
	for enemy_set in _enemy_sets:
		for subgroup in enemy_set.subgroups:
			if subgroup != null:
				for position in subgroup.positions:
					for enemy in position.enemies:
						enemy.apply_suggested_blood_orbs()
						enemy.apply_suggested_high_orbs()
						enemy.apply_suggested_exp()
						enemy.apply_suggested_play_points()
						enemy.emit_changed()
						
func apply_suggested_values_for_shops() -> void:
	for shop in _shops:
		for good in shop.get_goods():
			good.apply_suggested_price()


func clear_gathering_spots() -> void:
	for spot in _gathering_spots:
		spot.clear_gathering_items()

func get_gathering_spot(stage_id: int, group_id: int, subgroup_id: int) -> GatheringSpot:
	# Inefficient af
	for gathering_spot in _gathering_spots:
		if gathering_spot.stage_id == stage_id and gathering_spot.group_id == group_id and gathering_spot.subgroup_id == subgroup_id:
			return gathering_spot
	
	var gathering_spot := GatheringSpot.new(stage_id, group_id, subgroup_id)
	_gathering_spots.append(gathering_spot)
	return gathering_spot

func get_all_gathering_spots() -> Array:
	return Array(_gathering_spots)


func clear_shops() -> void:
	for shop in _shops:
		shop.clear_goods()
		
func get_shop(shop_id: int) -> Shop:
	for shop in _shops:
		if shop.id == shop_id:
			return shop
			
	var shop := Shop.new(shop_id)
	_shops.append(shop)
	return shop
	
func get_all_shops() -> Array:
	return Array(_shops)
