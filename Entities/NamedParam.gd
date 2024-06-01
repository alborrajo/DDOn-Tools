extends Resource
class_name NamedParam

const TRANSLATION_KEY_FORMAT = "NAMED_PARAM_%s"

enum Type {NAMED_TYPE_NONE = 1, NAMED_TYPE_PREFIX = 2, NAMED_TYPE_SUFFIX = 3, NAMED_TYPE_REPLACE = 4}

var id: int
var type: int
var hpRate: int
var experience: int
var attackBasePhys: int
var attackWepPhys: int
var defenceBasePhys: int
var defenceWepPhys: int
var attackBaseMagic: int
var attackWepMagic: int
var defenceBaseMagic: int
var defenceWepMagic: int
var power: int
var guardDefenceBase: int
var guardDefenceWep: int
var shrinkEnduranceMain: int
var blowEnduranceMain: int
var downEnduranceMain: int
var shakeEnduranceMain: int
var hpSub: int
var shrinkEnduranceSub: int
var blowEnduranceSub: int
var ocdEndurance: int
var ailmentDamage: int

func _init(named_param_dict: Dictionary):
	id = named_param_dict["ID"]
	type = named_param_dict["Type"]
	hpRate = named_param_dict["HpRate"]
	experience = named_param_dict["Experience"]
	attackBasePhys = named_param_dict["AttackBasePhys"]
	attackWepPhys = named_param_dict["AttackWepPhys"]
	defenceBasePhys = named_param_dict["DefenceBasePhys"]
	defenceWepPhys = named_param_dict["DefenceWepPhys"]
	attackBaseMagic = named_param_dict["AttackBaseMagic"]
	attackWepMagic = named_param_dict["AttackWepMagic"]
	defenceBaseMagic = named_param_dict["DefenceBaseMagic"]
	defenceWepMagic = named_param_dict["DefenceWepMagic"]
	power = named_param_dict["Power"]
	guardDefenceBase = named_param_dict["GuardDefenceBase"]
	guardDefenceWep = named_param_dict["GuardDefenceWep"]
	shrinkEnduranceMain = named_param_dict["ShrinkEnduranceMain"]
	blowEnduranceMain = named_param_dict["BlowEnduranceMain"]
	downEnduranceMain = named_param_dict["DownEnduranceMain"]
	shakeEnduranceMain = named_param_dict["ShakeEnduranceMain"]
	hpSub = named_param_dict["HpSub"]
	shrinkEnduranceSub = named_param_dict["ShrinkEnduranceSub"]
	blowEnduranceSub = named_param_dict["BlowEnduranceSub"]
	ocdEndurance = named_param_dict["OcdEndurance"]
	ailmentDamage = named_param_dict["AilmentDamage"]

func format_name(name: String) -> String:
	var translated_named_param_text := tr(TRANSLATION_KEY_FORMAT % [id])
	if type == Type.NAMED_TYPE_NONE:
		return name
	elif type == Type.NAMED_TYPE_PREFIX:
		return translated_named_param_text+" "+name
	elif type == Type.NAMED_TYPE_REPLACE:
		return translated_named_param_text
	elif type == Type.NAMED_TYPE_SUFFIX:
		return name+" "+translated_named_param_text
	else:
		printerr("Unknown named params type ", type)
		return name

func to_string() -> String:
	return "Id: %d\nType: %d\nHp rate: %d%%\nExperience: %d%%\nAttack base phys: %d%%\nAttack wep phys: %d%%\nDefence base phys: %d%%\nDefence wep phys: %d%%\nAttack base magic: %d%%\nAttack wep magic: %d%%\nDefence base magic: %d%%\nDefence wep magic: %d%%\nPower: %d%%\nGuard defence base: %d%%\nGuard defence wep: %d%%\nShrink endurance main: %d%%\nBlow endurance main: %d%%\nDown endurance main: %d%%\nShake endurance main: %d%%\nHp sub: %d%%\nShrink endurance sub: %d%%\nBlow endurance sub: %d%%\nOcd endurance: %d%%\nAilment damage: %d%%\n" % [id, type, hpRate, experience, attackBasePhys, attackWepPhys, defenceBasePhys, defenceWepPhys, attackBaseMagic, attackWepMagic, defenceBaseMagic, defenceWepMagic, power, guardDefenceBase, guardDefenceWep, shrinkEnduranceMain, blowEnduranceMain, downEnduranceMain, shakeEnduranceMain, hpSub, shrinkEnduranceSub, blowEnduranceSub, ocdEndurance, ailmentDamage]
