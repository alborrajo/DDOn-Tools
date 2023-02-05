extends Tree
class_name Players

signal player_joined(player)
signal player_updated(player)
signal player_left(player)

var rpc_client := RpcClient.new()

onready var players_on_ui_root: TreeItem = create_item()


func _ready():
	# Request RPC immediately
	update_info()

func _on_rpc_timer_timeout():
	update_info()


func update_info():
	var infos : Array = rpc_client.get_info()
	var item = false
	if get_root():
		item = get_root().get_children()
	while (item):
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if item.get_metadata(0).CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on ui, that have no info
			emit_signal("player_left", item.get_metadata(0))
			var tmp = item
			item = item.get_next()
			players_on_ui_root.remove_child(tmp)
			tmp.free()
			continue
		item = item.get_next()
			
	for info in infos:
		var player: Player
		player = Player.new(info)
			
		# on ui
		var stage_id := DataProvider.stage_no_to_stage_id(player.StageNo)
		var text := "%s %s @ %s %s" % [player.FirstName, player.LastName, tr(str("STAGE_NAME_",stage_id)), player.get_map_position().round()]
		
		var existing_ui : TreeItem
		item = false
		if get_root():
			item = get_root().get_children()
		while (item):
			if item.get_metadata(0).CharacterId == player.CharacterId:
				existing_ui = item
			item = item.get_next()
		if existing_ui:
			# update existing player
			existing_ui.set_text(0, text)
			emit_signal("player_updated", player)
		else:
			# create new player
			create_tree_entry(player)
			emit_signal("player_joined", player)
			

func create_tree_entry(var player: Player):
	var stage_id := DataProvider.stage_no_to_stage_id(player.StageNo)
	var text := "%s %s @ %s %s" % [player.FirstName, player.LastName, tr(str("STAGE_NAME_",stage_id)), player.get_map_position().round()]
	var item = create_item(players_on_ui_root)
	item.set_text(0, text)
	item.set_metadata(0, player)



