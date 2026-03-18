extends Resource
class_name ShopItemRequirement

# No conditions
const REQUIREMENT_CONDITION_NONE = 1

# {Param2 -> ???} cleared with rank {Param1} or better. (Final result {Progress} rank)
# Not sure how this is parsed, probably needs a questScheduleId for a quest in the right category.
const REQUIREMENT_CONDITION_CLEAR_WITH_RANK = 2

# Defeat {Param3 -> EnemyName} x{Param1} ({Progress}/{Param1})
const REQUIREMENT_CONDITION_DEFEAT_ENEMIES = 3

# Acquire War Mission Accumulated Points, {Param1} pt. ({Progress}/{Param1})
const REQUIREMENT_CONDITION_WAR_MISSION_POINTS = 4

# "Currently selected job with Play point content already released."
const REQUIREMENT_CONDITION_UNLOCK_PLAY_POINTS = 5

# Defeat LV.{Param2} or more {Param3 -> EnemyName} x{Param1} ({Progress}/{Param1})
const REQUIREMENT_CONDITION_DEFEAT_ENEMIESLEVEL = 6


const DEFAULT_DATE_STRING = "1970-01-01T00:00:00"


var condition: int = REQUIREMENT_CONDITION_NONE: set = _set_condition
var ignore_requirements: bool: set = _set_ignore_requirements
var hide_requirement_details: bool: set = _set_hide_requirement_details
var param1: int: set = _set_param1
var param2: int: set = _set_param2
var param3: int: set = _set_param3
var param4: int: set = _set_param4
var param5: int: set = _set_param5
var sales_period_start: String = DEFAULT_DATE_STRING: set = _set_sales_period_start
var sales_period_end: String = DEFAULT_DATE_STRING: set = _set_sales_period_end

func clone() -> ShopItemRequirement:
	var clone_new: ShopItemRequirement = get_script().new()
	clone_new.condition = condition
	clone_new.ignore_requirements = ignore_requirements
	clone_new.hide_requirement_details = hide_requirement_details
	clone_new.param1 = param1
	clone_new.param2 = param2
	clone_new.param3 = param3
	clone_new.param4 = param4
	clone_new.param5 = param5
	clone_new.sales_period_start = sales_period_start
	clone_new.sales_period_end = sales_period_end
	return clone_new

func _set_condition(value):
	condition = value
	emit_changed()

func _set_ignore_requirements(value):
	ignore_requirements = value
	emit_changed()

func _set_hide_requirement_details(value):
	hide_requirement_details = value
	emit_changed()

func _set_param1(value):
	param1 = value
	emit_changed()

func _set_param2(value):
	param2 = value
	emit_changed()

func _set_param3(value):
	param3 = value
	emit_changed()

func _set_param4(value):
	param4 = value
	emit_changed()

func _set_param5(value):
	param5 = value
	emit_changed()

func _set_sales_period_start(value):
	sales_period_start = value
	emit_changed()

func _set_sales_period_end(value):
	sales_period_end = value
	emit_changed()
