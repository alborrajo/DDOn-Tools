extends Resource
class_name Enemy

var enemy_type: EnemyType setget _set_enemy_type
var named_enemy_params_id: int = 0x8FA setget _set_named_enemy_params_id
var raid_boss_id: int = 0 setget _set_raid_boss_id
var scale: int = 100 setget _set_scale
var lv: int = 10 setget _set_lv
var hm_preset_no: int = 0 setget _set_hm_preset_no
var start_think_tbl_no: int = 0 setget _set_start_think_tbl_no
var repop_num: int = 0 setget _set_repop_num
var repop_count: int = 0 setget _set_repop_count
var enemy_target_types_id: int = 1 setget _set_enemy_target_types_id
var montage_fix_no: int = 0 setget _set_montage_fix_no
var set_type: int = 0 setget _set_set_type
var infection_type: int = 0 setget _set_infection_type
var is_boss_gauge: bool = false setget _set_is_boss_gauge
var is_boss_bgm: bool = false setget _set_is_boss_bgm
var is_manual_set: bool = false setget _set_is_manual_set
var is_area_boss: bool = false setget _set_is_area_boss
var is_blood_enemy: bool = false setget _set_is_blood_enemy
var is_highorb_enemy: bool = false setget _set_is_highorb_enemy

func _init(type: EnemyType):
	self.enemy_type = type
	self.hm_preset_no = type.default_hm_preset_no

func _set_enemy_type(value):
	enemy_type = value
	emit_changed()
	
func _set_named_enemy_params_id(value):
	named_enemy_params_id = value
	emit_changed()
	
func _set_raid_boss_id(value):
	raid_boss_id = value
	emit_changed()
	
func _set_scale(value):
	scale = value
	emit_changed()
	
func _set_lv(value):
	lv = value
	emit_changed()
	
func _set_hm_preset_no(value):
	hm_preset_no = value
	emit_changed()
	
func _set_start_think_tbl_no(value):
	start_think_tbl_no = value
	emit_changed()
	
func _set_repop_num(value):
	repop_num = value
	emit_changed()
	
func _set_repop_count(value):
	repop_count = value
	emit_changed()
	
func _set_enemy_target_types_id(value):
	enemy_target_types_id = value
	emit_changed()
	
func _set_montage_fix_no(value):
	montage_fix_no = value
	emit_changed()
	
func _set_set_type(value):
	set_type = value
	emit_changed()
	
func _set_infection_type(value):
	infection_type = value
	emit_changed()
	
func _set_is_boss_gauge(value):
	is_boss_gauge = value
	emit_changed()
	
func _set_is_boss_bgm(value):
	is_boss_bgm = value
	emit_changed()
	
func _set_is_manual_set(value):
	is_manual_set = value
	emit_changed()
	
func _set_is_area_boss(value):
	is_area_boss = value
	emit_changed()
	
func _set_is_blood_enemy(value):
	is_blood_enemy = value
	emit_changed()
	
func _set_is_highorb_enemy(value):
	is_highorb_enemy = value
	emit_changed()
	
