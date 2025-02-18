extends Resource
class_name Enemy

const DEFAULT_NAMED_PARAMS_ID = 0x8FA

# By default, you have to kill 5 bosses or 50 enemies
# of your level to level up
const STORAGE_SECTION_ENEMIES := "Enemies"
const STORAGE_KEY_ENEMIES_TO_LEVEL_UP := "EnemiesToLevelUp"
const STORAGE_KEY_ENEMIES_TO_LEVEL_UP_DEFAULT := 50;
const STORAGE_KEY_BOSSES_TO_LEVEL_UP := "BossesToLevelUp"
const STORAGE_KEY_BOSSES_TO_LEVEL_UP_DEFAULT := 5;

const EXP_UNTIL_NEXT_LV := [
	0,
	300, # Lv 1 
	500, # Lv 2 
	800, # Lv 3 
	1200, # Lv 4 
	1700, # Lv 5 
	2300, # Lv 6 
	3000, # Lv 7 
	3800, # Lv 8 
	4700, # Lv 9 
	5700, # Lv 10
	6800, # Lv 11
	8000, # Lv 12
	9300, # Lv 13
	10700, # Lv 14
	12200, # Lv 15
	13800, # Lv 16
	15500, # Lv 17
	17300, # Lv 18
	19200, # Lv 19
	21200, # Lv 20
	23300, # Lv 21
	25500, # Lv 22
	27800, # Lv 23
	30200, # Lv 24
	32700, # Lv 25
	35300, # Lv 26
	38000, # Lv 27
	40800, # Lv 28
	43700, # Lv 29
	46700, # Lv 30
	49800, # Lv 31
	53000, # Lv 32
	56300, # Lv 33
	59700, # Lv 34
	63200, # Lv 35
	66800, # Lv 36
	70500, # Lv 37
	74300, # Lv 38
	78200, # Lv 39
	152500, # Lv 40
	187100, # Lv 41
	210000, # Lv 42
	235300, # Lv 43
	263200, # Lv 44
	267700, # Lv 45
	272300, # Lv 46
	277000, # Lv 47
	281800, # Lv 48
	286700, # Lv 49
	291700, # Lv 50
	296800, # Lv 51
	302000, # Lv 52
	307300, # Lv 53
	312700, # Lv 54
	318200, # Lv 55
	323800, # Lv 56
	329500, # Lv 57
	335300, # Lv 58
	341200, # Lv 59
	756600, # Lv 60
	762700, # Lv 61
	768900, # Lv 62
	775200, # Lv 63
	781600, # Lv 64
	788100, # Lv 65
	985000, # Lv 66
	1085000, # Lv 67
	1185000, # Lv 68
	1335000, # Lv 69
	1535000, # Lv 70 (PP Unlocked)
	1735000, # Lv 71
	1935000, # Lv 72
	2185000, # Lv 73
	2435000, # Lv 74
	2735000, # Lv 75
	3035000, # Lv 76
	3335000, # Lv 77
	3685000, # Lv 78
	4035000, # Lv 79
	4200000, # Lv 80 
	4200000, # Lv 81
	4200000, # Lv 82
	4200000, # Lv 83
	4200000, # Lv 84
	4200000, # Lv 85
	4200000, # Lv 86
	4200000, # Lv 87
	4200000, # Lv 88
	4200000, # Lv 89
	4200000, # Lv 90
	4200000, # Lv 91
	4200000, # Lv 92
	4200000, # Lv 93
	4200000, # Lv 94
	4200000, # Lv 95
	4200000, # Lv 96
	4200000, # Lv 97
	4200000, # Lv 98
	4200000, # Lv 99
	4461000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 10
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
	5000000, # Lv 11
]

var enemy_type: EnemyType setget _set_enemy_type
var named_param: NamedParam setget _set_named_param
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
var time_type: int = 0 setget _set_time_type
var custom_time: String = "00:00,23:59" setget _set_custom_time
var is_boss_gauge: bool = false setget _set_is_boss_gauge
var is_boss_bgm: bool = false setget _set_is_boss_bgm
var is_manual_set: bool = false setget _set_is_manual_set
var is_area_boss: bool = false setget _set_is_area_boss
var is_blood_enemy: bool = false setget _set_is_blood_enemy
var blood_orbs: int = 0 setget _set_blood_orbs
var is_highorb_enemy: bool = false setget _set_is_highorb_enemy
var high_orbs: int = 0 setget _set_high_orbs
var experience: int = 0 setget _set_experience
var play_points: int = 0 setget _set_play_points
var drops_table: DropsTable = null setget _set_drops_table

func _init(type: EnemyType, np: NamedParam = null):
	self.enemy_type = type
	if np == null:
		self.named_param = DataProvider.get_named_param_by_id(DEFAULT_NAMED_PARAMS_ID)
	else:
		self.named_param = np
	_set_lv(self.lv) # Update values dependant on Lv

func get_display_name() -> String:
	return "%s (Lv. %d)" % [named_param.format_name(enemy_type.name), lv]

func clone() -> Enemy:
	var new_enemy: Enemy = get_script().new(self.enemy_type)
	new_enemy.named_param = self.named_param
	new_enemy.raid_boss_id = self.raid_boss_id
	new_enemy.scale = self.scale
	new_enemy.lv = self.lv
	new_enemy.hm_preset_no = self.hm_preset_no
	new_enemy.start_think_tbl_no = self.start_think_tbl_no
	new_enemy.repop_num = self.repop_num
	new_enemy.repop_count = self.repop_count
	new_enemy.enemy_target_types_id = self.enemy_target_types_id
	new_enemy.montage_fix_no = self.montage_fix_no
	new_enemy.set_type = self.set_type
	new_enemy.infection_type = self.infection_type
	new_enemy.time_type = self.time_type
	new_enemy.custom_time = self.custom_time
	new_enemy.is_boss_gauge = self.is_boss_gauge
	new_enemy.is_boss_bgm = self.is_boss_bgm
	new_enemy.is_manual_set = self.is_manual_set
	new_enemy.is_area_boss = self.is_area_boss
	new_enemy.is_blood_enemy = self.is_blood_enemy
	new_enemy.blood_orbs = self.blood_orbs
	new_enemy.is_highorb_enemy = self.is_highorb_enemy
	new_enemy.high_orbs = self.high_orbs
	new_enemy.experience = self.experience
	new_enemy.play_points = self.play_points
	new_enemy.drops_table = self.drops_table
	return new_enemy

func _set_enemy_type(value):
	enemy_type = value
	hm_preset_no = value.default_hm_preset_no
	emit_changed()
	
func _set_named_param(value):
	named_param = value
	emit_changed()
	
func _set_raid_boss_id(value):
	raid_boss_id = value
	emit_changed()
	
func _set_scale(value):
	scale = value
	emit_changed()
	
func _set_lv(value):
	lv = value
	blood_orbs = value
	high_orbs = value
	_calculate_exp()
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
	
func _set_time_type(value):
	time_type = value
	emit_changed()
	
func _set_custom_time(value: String) -> void:
	var regex := "^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9],(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
	# using a Regex to define a valid format for the timestamp
	if _validate_time_format(value, regex):
		custom_time = value
		emit_changed()

func _validate_time_format(time_str: String, regex_str: String) -> bool:
	var regex := RegEx.new()
	assert(regex.compile(regex_str) == OK)
	
	return regex.search(time_str) != null

func _set_is_boss_gauge(value):
	is_boss_gauge = value
	_calculate_exp()
	emit_changed()
	
func _set_is_boss_bgm(value):
	is_boss_bgm = value
	_calculate_exp()
	emit_changed()
	
func _set_is_manual_set(value):
	is_manual_set = value
	emit_changed()
	
func _set_is_area_boss(value):
	is_area_boss = value
	_calculate_exp()
	emit_changed()
	
func _set_is_blood_enemy(value):
	is_blood_enemy = value
	emit_changed()

func _set_blood_orbs(value):
	blood_orbs = value
	emit_changed()
	
func _set_is_highorb_enemy(value):
	is_highorb_enemy = value
	emit_changed()

func _set_high_orbs(value):
	high_orbs = value
	emit_changed()
	
func _set_experience(value):
	experience = value
	emit_changed()

func _set_play_points(value):
	play_points = value
	emit_changed()

func _set_drops_table(value):
	drops_table = value
	emit_changed()

func _calculate_exp() -> void:
	var next_level_idx := clamp(lv+1, 0, len(EXP_UNTIL_NEXT_LV)-1)
	var exp_to_level_up: int = EXP_UNTIL_NEXT_LV[next_level_idx]
	if is_area_boss or is_boss_bgm or is_boss_gauge:
		experience = int(exp_to_level_up / StorageProvider.get_value(STORAGE_SECTION_ENEMIES, STORAGE_KEY_BOSSES_TO_LEVEL_UP, STORAGE_KEY_BOSSES_TO_LEVEL_UP_DEFAULT))
	else:
		experience = int(exp_to_level_up / StorageProvider.get_value(STORAGE_SECTION_ENEMIES, STORAGE_KEY_ENEMIES_TO_LEVEL_UP, STORAGE_KEY_ENEMIES_TO_LEVEL_UP_DEFAULT))
