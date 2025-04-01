extends Tree
class_name Players

const STORAGE_SECTION_PLAYERS := "Players"
const STORAGE_KEY_SHOW_IN_ALL_TABS := "ShowInAllTabs"
const STORAGE_KEY_SHOW_IN_ALL_TABS_DEFAULT := false;

signal player_joined(player)
signal player_updated(player)
signal player_left(player)

var _thread: Thread

onready var servers_on_ui_root: TreeItem = create_item()

func _ready():
	# Request RPC immediately
	update_servers()

func _on_rpc_timer_timeout():
	# If there's an old thread that hasn't finished, don't start a new one
	# if there's an old thread that has finished, join it and start a new one
	# if there's no old thread, start a new one
	if _thread != null and _thread.is_active():
		if not _thread.is_alive():
			_thread.wait_to_finish()
		else:
			return
		
	_thread = Thread.new()
	assert(_thread.start(self, "update_servers") == OK)

# TODO: Refactor for less code duplication when updating trees
func update_servers():
	var servers: Array = RpcClient.new().get_status()
	var server_item = false
	if get_root():
		server_item = get_root().get_children()
	while (server_item):
		var server_item_metadata = server_item.get_metadata(0)
		var exists = false
		for server in servers:
			var server_item_host: String = server_item_metadata["Addr"]
			var server_item_rpc_port: int = server_item_metadata["RpcPort"]
			var server_host: String = server["Addr"]
			var server_rpc_port: int = server["RpcPort"]
			if server_item_host == server_host and server_item_rpc_port == server_rpc_port:
				exists = true
				break
		var tmp = server_item
		server_item = server_item.get_next()
		if !exists:
			# remove servers on ui, that have no info
			servers_on_ui_root.remove_child(tmp)
			tmp.free()
			
	for server in servers:
		var server_host: String = server["Addr"]
		var server_rpc_port: int = server["RpcPort"]
		var existing_ui: TreeItem
		server_item = null
		if get_root():
			server_item = get_root().get_children()
		while (server_item):
			var server_item_metadata = server_item.get_metadata(0)
			var server_item_host: String = server_item_metadata["Addr"]
			var server_item_rpc_port: int = server_item_metadata["RpcPort"]
			if server_item_host == server_host and server_item_rpc_port == server_rpc_port:
				break
			server_item = server_item.get_next()
		if server_item != null:
			# update existing server
			_update_server_tree_entry(existing_ui, server)
		else:
			# create new server
			server_item = create_item(servers_on_ui_root)
			_update_server_tree_entry(server_item, server)
		# Update the server's player list
		_update_server_info(server_item)
			
func _update_server_info(server_item: TreeItem):
	var server_item_metadata = server_item.get_metadata(0)
	var server_item_host: String = server_item_metadata["Addr"]
	var server_item_rpc_port: int = server_item_metadata["RpcPort"]
	var infos : Array = RpcClient.new(server_item_host, server_item_rpc_port).get_info()
	print("PACO", infos)
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
			emit_signal("player_updated", player)
		else:
			# create new player
			var entry := create_item(server_item)
			_update_player_tree_entry(entry, player)
			emit_signal("player_joined", player)


func _update_server_tree_entry(item: TreeItem, server: Dictionary):
	item.set_text(0, server["Name"])
	item.set_metadata(0, server)

func _update_player_tree_entry(item: TreeItem, player: PlayerMapEntity):
	var stage_id := DataProvider.stage_no_to_stage_id(player.StageNo)
	var text := "%s %s @ %s %s" % [player.FirstName, player.LastName, tr(str("STAGE_NAME_",stage_id)), MapControl.get_map_position(player.StageNo, player.pos).round()]
	item.set_text(0, text)
	item.set_metadata(0, player)

func _on_Players_item_rmb_selected(_position):
	var selection: TreeItem = get_selected()
	var selection_meta = selection.get_metadata(0)
	if selection_meta is PlayerMapEntity:
		var player = selection_meta as PlayerMapEntity
		var server_item_metadata = selection.get_parent().get_metadata(0)
		var server_item_host: String = server_item_metadata["Addr"]
		var server_item_rpc_port: int = server_item_metadata["RpcPort"]
		
		# TODO: Use translations
		$KickConfirmationDialog.dialog_text = "Kick %s %s?" % [player.FirstName, player.LastName]
		if $KickConfirmationDialog.is_connected("confirmed", self, "_on_KickConfirmationDialog_confirmed"):
			$KickConfirmationDialog.disconnect("confirmed", self, "_on_KickConfirmationDialog_confirmed")
		assert($KickConfirmationDialog.connect("confirmed", self, "_on_KickConfirmationDialog_confirmed", [server_item_host, server_item_rpc_port, player], CONNECT_ONESHOT) == OK)
		$KickConfirmationDialog.popup_centered()

func _on_KickConfirmationDialog_confirmed(server_host: String, server_port: int, player: PlayerMapEntity):
	RpcClient.new(server_host, server_port).delete_info(player.AccountName)
	update_servers()

func _exit_tree():
	if _thread != null and _thread.is_active():
		_thread.wait_to_finish()
