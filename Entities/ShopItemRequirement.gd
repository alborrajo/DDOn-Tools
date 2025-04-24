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


var condition: int setget _set_condition
var ignore_requirements: bool setget _set_ignore_requirements
var progress: int setget _set_progress
var hide_requirement_details: bool setget _set_hide_requirement_details
var param1: int setget _set_param1
var param2: int setget _set_param2
var param3: int setget _set_param3
var param4: int setget _set_param4
var param5: int setget _set_param5
var sales_period_start: int setget _set_sales_period_start
var sales_period_end: int setget _set_sales_period_end

func _set_condition(value):
  condition = value
  emit_changed()

func _set_ignore_requirements(value):
  ignore_requirements = value
  emit_changed()

func _set_progress(value):
  progress = value
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
