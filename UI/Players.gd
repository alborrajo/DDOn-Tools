extends Tree
class_name Players


const PlayerMarkerScene = preload("res://UI/Marker/PlayerMarker.tscn")

var rpc_client := RpcClient.new()

onready var players_on_ui_root: TreeItem = create_item()


func _ready():
	# Request RPC immediately
	#update_info()
	pass

func _on_rpc_timer_timeout():
	#update_info()
	pass


func update_info():
	var infos : Array = rpc_client.get_info()
	for n in get_children():
		# check if player is still in the server
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if n.player.CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on map, that have no info
			remove_child(n)
			n.queue_free()
	
	var item = false
	if get_root():
		item = get_root().get_children()
	while (item):
		var exists = false
		for info in infos:
			var CharacterId : int = info["CharacterId"]
			if item.get_metadata(0).player.CharacterId == CharacterId:
				exists = true
				break
		if !exists:
			# remove players on ui, that have no info
			var tmp = item
			item = item.get_next()
			players_on_ui_root.remove_child(tmp)
			tmp.free()
			continue
		item = item.get_next()
			
	for info in infos:
		var player: Player
		var field_id = DataProvider.stage_no_to_belonging_field_id(info["StageNo"])
		if field_id == null:
			player = Player.new(info)
		else: 
			player = Player.new(info, String(field_id))
		
		# on map
		var player_marker: PlayerMarker
		for n in get_children():
			if n.player.CharacterId == player.CharacterId:
				player_marker = n
		if player_marker:
			# update existing player
			player_marker.set_player(player)
			player_marker._on_ui_map_selected($ui.get_selected_map())
		else:
			# create new player
			player_marker = PlayerMarkerScene.instance()
			$ui.connect("map_selected", player_marker, "_on_ui_map_selected")
			player_marker.set_player(player)
			player_marker._on_ui_map_selected($ui.get_selected_map())
			add_child(player_marker)
			
		# on ui
		var stage_id := DataProvider.stage_no_to_stage_id(player.StageNo)
		var text := "%s %s @ %s %s" % [player.FirstName, player.LastName, tr(str("STAGE_NAME_",stage_id)), player.get_map_position().round()]
		
		var existing_ui : TreeItem
		item = false
		if get_root():
			item = get_root().get_children()
		while (item):
			if item.get_metadata(0).player.CharacterId == player.CharacterId:
				existing_ui = item
			item = item.get_next()
		if existing_ui:
			# update existing player
			existing_ui.set_text(0, text)
		else:
			# create new player
			create_tree_entry(player_marker)
			

func create_tree_entry(var player_marker : PlayerMarker):
	var stage_id := DataProvider.stage_no_to_stage_id(player_marker.player.StageNo)
	var text := "%s %s @ %s %s" % [player_marker.player.FirstName, player_marker.player.LastName, tr(str("STAGE_NAME_",stage_id)), player_marker.player.get_map_position().round()]
	var item = create_item(players_on_ui_root)
	item.set_text(0, text)
	item.set_metadata(0, player_marker)



