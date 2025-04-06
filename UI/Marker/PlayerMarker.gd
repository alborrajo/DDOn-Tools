extends MapControl
class_name PlayerMarker

var player: PlayerMapEntity
var _current_map_stage_no: int = -1

func set_player(var p_player : PlayerMapEntity):
	player = p_player
	_update_visibility()
	set_ddon_world_position(player.StageNo, player.pos)
	$PlayerNameLabel.text = "%s %s" % [player.FirstName, player.LastName]
	
func _update_visibility():
	visible = _current_map_stage_no == player.StageNo
	
func _on_ui_stage_selected(new_map_stage_no):
	_current_map_stage_no = int(new_map_stage_no)
	_update_visibility()
