extends Resource
class_name Enemy

var enemy_type: EnemyType
var named_enemy_params_id: int = 0x8FA
var raid_boss_id: int = 0
var scale: int = 100
var lv: int = 10
var hm_preset_no: int = 0
var start_think_tbl_no: int = 0
var repop_num: int = 0
var repop_count: int = 0
var enemy_target_types_id: int = 1
var montage_fix_no: int = 0
var set_type: int = 0
var infection_type: int = 0
var is_boss_gauge: bool = false
var is_boss_bgm: bool = false
var is_manual_set: bool = false
var is_area_boss: bool = false
var is_blood_enemy: bool = false
var is_highorb_enemy: bool = false

func _init(type: EnemyType):
	self.enemy_type = type
	self.hm_preset_no = type.default_hm_preset_no
