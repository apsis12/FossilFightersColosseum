extends Object

class_name Skill

var label:String
var type:int
var shown_type:int

var power:int
var fp:int
var hit_cnt:int
var target:int

var effect:int
var status_effect:int

var effect_severity:int
var effect_descriptor:String
var effect_chance:float

var transform_type

enum SKILL_TYPE {
	ATTACK,
	SPECIAL,
	TEAM,
	TRANSFORM,
}

enum EFFECT {
	NONE,
	STATUS,
	LAW_OF_THE_JUNGLE,
	SACRIFICE,
	FP_EQUALIZE,
	KNOCK,
	HEAL,
	STEAL_FP,
	STEAL_LP,
	TRANSFORM,
	NEUTRALIZE,
	DISPLACE,
	KAMIKAZE,
}

static func str_effect(inp:int) -> String:
	match inp:
		EFFECT.NONE: return "none"
		EFFECT.STATUS: return "status"
		EFFECT.LAW_OF_THE_JUNGLE: return "sacrifice ally"
		EFFECT.SACRIFICE: return "sacrifice self"
		EFFECT.FP_EQUALIZE: return "equalize fp"
		EFFECT.KNOCK: return "knock to sz"
		EFFECT.HEAL: return "heal lp"
		EFFECT.STEAL_FP: return "steal fp"
		EFFECT.STEAL_LP: return "steal lp"
		EFFECT.TRANSFORM: return "transform"
		EFFECT.NEUTRALIZE: return "eliminate effects"
		EFFECT.DISPLACE: return "displace enemy team"
		EFFECT.KAMIKAZE: return "kamikaze"
	assert(false)
	return ""

enum STATUS_EFFECT {
	CONFUSE,
	ENRAGE,
	EXCITE,
	POISON,
	SCARE,
	SLEEP,
	COUNTER,
	ENFLAME,
	HARDEN,
	QUICKEN,
}

static func get_status_turn_endurance(inp:int) -> int:
	match inp:
		STATUS_EFFECT.CONFUSE: return 2
		STATUS_EFFECT.ENRAGE: return 2
		STATUS_EFFECT.EXCITE: return 2
		STATUS_EFFECT.POISON: return 1
		STATUS_EFFECT.SCARE: return 2
		STATUS_EFFECT.SLEEP: return 2
		STATUS_EFFECT.COUNTER: return 2
		STATUS_EFFECT.ENFLAME: return 1
		STATUS_EFFECT.HARDEN: return 1
		STATUS_EFFECT.QUICKEN: return 1
	assert(false)
	return -1

static func str_status(inp:int) -> String:
	match inp:
		STATUS_EFFECT.CONFUSE: return "confuse"
		STATUS_EFFECT.ENRAGE: return "enrage"
		STATUS_EFFECT.EXCITE: return "excite"
		STATUS_EFFECT.POISON: return "poison"
		STATUS_EFFECT.SCARE: return "scare"
		STATUS_EFFECT.SLEEP: return "sleep"
		STATUS_EFFECT.COUNTER: return "counter"
		STATUS_EFFECT.ENFLAME: return "raise attack"
		STATUS_EFFECT.HARDEN: return "raise defense"
		STATUS_EFFECT.QUICKEN: return "raise evasion"
	assert(false)
	return ""

static func str_status_adj(inp:int) -> String:
	match inp:
		STATUS_EFFECT.CONFUSE: return "confused"
		STATUS_EFFECT.ENRAGE: return "enraged"
		STATUS_EFFECT.EXCITE: return "excited"
		STATUS_EFFECT.POISON: return "poisoned"
		STATUS_EFFECT.SCARE: return "scared"
		STATUS_EFFECT.SLEEP: return "asleep"
		STATUS_EFFECT.COUNTER: return "countering"
		STATUS_EFFECT.ENFLAME: return "enflamed"
		STATUS_EFFECT.HARDEN: return "hardened"
		STATUS_EFFECT.QUICKEN: return "quickened"
	assert(false)
	return ""

static func str_status_info(inp:int) -> String:
	match inp:
		STATUS_EFFECT.CONFUSE: return "confuse opponent"
		STATUS_EFFECT.ENRAGE: return "enrage opponent"
		STATUS_EFFECT.EXCITE: return "excite opponent"
		STATUS_EFFECT.POISON: return "poison opponent"
		STATUS_EFFECT.SCARE: return "scare opponent"
		STATUS_EFFECT.SLEEP: return "inflict sleep"
		STATUS_EFFECT.COUNTER: return "counter"
		STATUS_EFFECT.ENFLAME: return "raise attack"
		STATUS_EFFECT.HARDEN: return "raise defense"
		STATUS_EFFECT.QUICKEN: return "raise evasion"
	assert(false)
	return ""

static func str_status_sentence(inp:int) -> String:
	match inp:
		STATUS_EFFECT.CONFUSE: return "was confused"
		STATUS_EFFECT.ENRAGE: return "was enraged"
		STATUS_EFFECT.EXCITE: return "was excited"
		STATUS_EFFECT.POISON: return "was poisoned"
		STATUS_EFFECT.SCARE: return "was scared"
		STATUS_EFFECT.SLEEP: return "was put to sleep"
		STATUS_EFFECT.COUNTER: return "is countering"
		STATUS_EFFECT.ENFLAME: return "had its attack raised"
		STATUS_EFFECT.HARDEN: return "had its defense raised"
		STATUS_EFFECT.QUICKEN: return "had its evasion raised"
	assert(false)
	return ""

static func get_status_effect_icon(inp:int, severity:int) -> StreamTexture:
	match inp:
		STATUS_EFFECT.CONFUSE:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Confusion.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Confusion.png")
		STATUS_EFFECT.ENRAGE:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Enrage.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Enrage.png")
		STATUS_EFFECT.EXCITE:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Excite.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Excite.png")
		STATUS_EFFECT.POISON:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Poison.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Poison.png")
				3: return preload("res://Assets/Icon/status_effect/Venom.png")
		STATUS_EFFECT.SCARE:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Scare.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Scare.png")
		STATUS_EFFECT.SLEEP:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Sleep.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Sleep.png")
		STATUS_EFFECT.COUNTER:
			if severity <= 40:
				return preload("res://Assets/Icon/status_effect/Counter.png")
			else:
				return preload("res://Assets/Icon/status_effect/Super_Counter.png")
		STATUS_EFFECT.ENFLAME:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Enflame.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Enflame.png")
		STATUS_EFFECT.HARDEN:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Harden.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Harden.png")
		STATUS_EFFECT.QUICKEN:
			match severity:
				1: return preload("res://Assets/Icon/status_effect/Quicken.png")
				2: return preload("res://Assets/Icon/status_effect/Super_Quicken.png")
	
	assert(false)
	return null

# team can be used on oneself, whereas ally cannot
enum TARGET {
	ENEMY,
	ALL_ENEMY,
	ALLY,
	TEAM,
	ALL_TEAM,
}

static func str_target(inp:int) -> String:
	match inp:
		TARGET.ENEMY: return "enemy"
		TARGET.ALL_ENEMY: return "all enemy"
		TARGET.ALLY: return "ally"
		TARGET.TEAM: return "team"
		TARGET.ALL_TEAM: return "all team"
	assert(false)
	return ""


func import(descriptor:Dictionary):
	label = descriptor["Skill"]
	
	if descriptor["Power"] != null:
		power = descriptor["Power"]
	fp = descriptor["FP"]
	
	match descriptor["Type"]:
		"Attack": type = SKILL_TYPE.ATTACK
		"Special": type = SKILL_TYPE.SPECIAL
		"Team": type = SKILL_TYPE.TEAM
		_: assert(false)
	match descriptor["Shown Type"]:
		"Attack": shown_type = SKILL_TYPE.ATTACK
		"Special": shown_type = SKILL_TYPE.SPECIAL
		"Team": shown_type = SKILL_TYPE.TEAM
		_: assert(false)
	
	if type != SKILL_TYPE.SPECIAL and descriptor["Hit Count"] != null:
		hit_cnt = descriptor["Hit Count"]
	
	if descriptor["Effect"] != null:
		match descriptor["Effect"]:
			"Displace": effect = EFFECT.DISPLACE
			"FP Equalize": effect = EFFECT.FP_EQUALIZE
			"Heal": effect = EFFECT.HEAL
			"Kamikaze": effect = EFFECT.KAMIKAZE
			"Knock": effect = EFFECT.KNOCK
			"LOJ": effect = EFFECT.LAW_OF_THE_JUNGLE
			"Eliminate Effects": effect = EFFECT.NEUTRALIZE
			"Steal FP": effect = EFFECT.STEAL_FP
			"Steal LP": effect = EFFECT.STEAL_LP
			"Transform": effect = EFFECT.TRANSFORM
			"Sacrifice": effect = EFFECT.SACRIFICE
			
			"Confuse":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.CONFUSE
			"Enrage":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.ENRAGE
			"Excite":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.EXCITE
			"Poison":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.POISON
			"Scare":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.SCARE
			"Sleep":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.SLEEP
			"Counter":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.COUNTER
			"Attack Up":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.ENFLAME
			"Defense Up":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.HARDEN
			"Evasion Up":
				effect = EFFECT.STATUS
				status_effect = STATUS_EFFECT.QUICKEN
			
			_: effect = EFFECT.NONE
		
		if descriptor["Severity"] is String:
			effect_descriptor = descriptor["Severity"]
		elif descriptor["Severity"] != null:
			effect_severity = descriptor["Severity"]
		effect_chance = float(descriptor["Chance"]) / 100.0
	
	match descriptor["Target"]:
		null,"Enemy": target = TARGET.ENEMY
		"All Enemy": target = TARGET.ALL_ENEMY
		"Ally": target = TARGET.ALLY
		"All Team": target = TARGET.ALL_TEAM
		"Team": target = TARGET.TEAM
