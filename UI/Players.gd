extends Tree
class_name Players

signal player_joined(player)
signal player_updated(player)
signal player_left(player)

onready var servers_on_ui_root: TreeItem = create_item()


func _ready():
	# Request RPC immediately
	update_servers()

func _on_rpc_timer_timeout():
	update_servers()

# TODO: Refactor for less code duplication when updating trees
func update_servers():
	var servers: Array = RpcClient.new().get_status()
	var server_item = false
	if get_root():
		server_item = get_root().get_children()
	while (server_item):
		var server_item_host = server_item.get_metadata(0) as String
		var exists = false
		for server in servers:
			var server_host: String = server["Addr"]
			if server_item_host == server_host:
				exists = true
				break
		if !exists:
			# remove servers on ui, that have no info
			var tmp = server_item
			server_item = server_item.get_next()
			servers_on_ui_root.remove_child(tmp)
			tmp.free()
		else:
			# Update the server's player list
			_update_server_info(server_item)
			server_item = server_item.get_next()
			
	for server in servers:
		var server_host: String = server["Addr"]
		var existing_ui: TreeItem
		server_item = false
		if get_root():
			server_item = get_root().get_children()
		while (server_item):
			if server_item.get_metadata(0) == server_host:
				existing_ui = server_item
			server_item = server_item.get_next()
		if existing_ui:
			# update existing player
			_update_server_tree_entry(existing_ui, server)
		else:
			# create new player
			var entry := create_item(servers_on_ui_root)
			_update_server_tree_entry(entry, server)
			
func _update_server_info(server_item: TreeItem):
	var server_item_host = server_item.get_metadata(0) as String
	var infos : Array = RpcClient.new(server_item_host).get_info()
	var item = server_item.get_children()
	while (item):
		var item_player = item.get_metadata(0) as PlayerMapEntity
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if item_player.CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on ui, that have no info
			print_debug("[%d] %s %s left", [item_player.CharacterId, item_player.FirstName, item_player.LastName])
			emit_signal("player_left", item_player)
			var tmp = item
			item = item.get_next()
			server_item.remove_child(tmp)
			tmp.free()
		else:
			item = item.get_next()
			
	for info in infos:
		var player := PlayerMapEntity.new(info)
		var existing_ui : TreeItem
		item = false
		if get_root():
			item = server_item.get_children()
		while (item):
			if item.get_metadata(0).CharacterId == player.CharacterId:
				existing_ui = item
			item = item.get_next()
		if existing_ui:
			# update existing player
			_update_player_tree_entry(existing_ui, player)
			print_debug("[%d] %s %s @ %d %s" % [player.CharacterId, player.FirstName, player.LastName, player.StageNo, player.pos.round()])
			emit_signal("player_updated", player)
		else:
			# create new player
			var entry := create_item(server_item)
			_update_player_tree_entry(entry, player)
			print_debug("[%d] %s %s @ %d %s joined" % [player.CharacterId, player.FirstName, player.LastName, player.StageNo, player.pos.round()])
			emit_signal("player_joined", player)


func _update_server_tree_entry(item: TreeItem, server: Dictionary):
	item.set_text(0, server["Name"])
	item.set_metadata(0, server["Addr"])

func _update_player_tree_entry(item: TreeItem, player: PlayerMapEntity):
	var stage_id := DataProvider.stage_no_to_stage_id(player.StageNo)
	var text := "%s %s @ %s %s" % [player.FirstName, player.LastName, tr(str("STAGE_NAME_",stage_id)), player.get_map_position().round()]
	item.set_text(0, text)
	item.set_metadata(0, player)

func _on_Players_item_rmb_selected(_position):
	var selection: TreeItem = get_selected()
	var selection_meta = selection.get_metadata(0)
	if selection_meta is PlayerMapEntity:
		var player = selection_meta as PlayerMapEntity
		var server_host: String = selection.get_parent().get_metadata(0)
		
		# TODO: Use translations
		$KickConfirmationDialog.dialog_text = "Kick %s %s?" % [player.FirstName, player.LastName]
		if $KickConfirmationDialog.is_connected("confirmed", self, "_on_KickConfirmationDialog_confirmed"):
			$KickConfirmationDialog.disconnect("confirmed", self, "_on_KickConfirmationDialog_confirmed")
		assert($KickConfirmationDialog.connect("confirmed", self, "_on_KickConfirmationDialog_confirmed", [server_host, player], CONNECT_ONESHOT) == OK)
		$KickConfirmationDialog.popup_centered()

func _on_KickConfirmationDialog_confirmed(server_host: String, player: PlayerMapEntity):
	RpcClient.new(server_host).delete_info(player.AccountName)
	print_debug("[%d] %s %s @ %d %s kicked" % [player.CharacterId, player.FirstName, player.LastName, player.StageNo, player.pos.round()])
	update_servers()
