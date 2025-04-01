extends MapControl
class_name PlayerMarker

var player: PlayerMapEntity

func set_player(var p_player : PlayerMapEntity):
	player = p_player
	set_ddon_world_position(player.StageNo, player.pos)
	$PlayerNameLabel.text = "%s %s" % [player.FirstName, player.LastName]
	
func _on_ui_stage_selected(new_map_stage_no):
	visible = int(new_map_stage_no) == player.StageNo
