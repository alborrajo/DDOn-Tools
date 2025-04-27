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


var condition: int = REQUIREMENT_CONDITION_NONE setget _set_condition
var ignore_requirements: bool setget _set_ignore_requirements
var hide_requirement_details: bool setget _set_hide_requirement_details
var param1: int setget _set_param1
var param2: int setget _set_param2
var param3: int setget _set_param3
var param4: int setget _set_param4
var param5: int setget _set_param5
var sales_period_start: String = DEFAULT_DATE_STRING setget _set_sales_period_start
var sales_period_end: String = DEFAULT_DATE_STRING setget _set_sales_period_end

func clone() -> ShopItemRequirement:
	var clone: ShopItemRequirement = get_script().new()
	clone.condition = condition
	clone.ignore_requirements = ignore_requirements
	clone.hide_requirement_details = hide_requirement_details
	clone.param1 = param1
	clone.param2 = param2
	clone.param3 = param3
	clone.param4 = param4
	clone.param5 = param5
	clone.sales_period_start = sales_period_start
	clone.sales_period_end = sales_period_end
	return clone

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
