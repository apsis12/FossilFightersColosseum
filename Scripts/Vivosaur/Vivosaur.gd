extends Object

class_name Vivosaur

signal index_changed()

var dbentry:VivoDBEntry

func _init(index_input:int = 0, level_input:int = 12):
	set_list_index(index_input)
	set_level(level_input)


var list_index :int = 0 setget set_list_index
func set_list_index(input):
	if range(Vivodata.metadb.size()).has(input):
		list_index = input
		dbentry = Vivodata.metadb[list_index]
		emit_signal("index_changed")
		set_default_stats()

var level:int = 12 setget set_level
func set_level(input):
	level = int(clamp(input, 1, 12))


# stats
var lp         :int = 0

var attack     :int = 0
var defense    :int = 0
var accuracy   :int = 0
var evasion    :int = 0

# support effects
var sattack    :int = 0
var sdefense   :int = 0
var saccuracy  :int = 0
var sevasion   :int = 0


func get_stats() -> PoolIntArray:
	return PoolIntArray([lp, attack, defense, accuracy, evasion])

func get_support_effects() -> PoolIntArray:
	return PoolIntArray([sattack, sdefense, saccuracy, sevasion])

func get_all_stats() -> PoolIntArray:
	return get_stats() + get_support_effects()


func get_crit_rate() -> float:
	return BattleSettings.default_crit_rate if dbentry.crit_rate == 0 else dbentry.crit_rate as float


func set_default_stats():
	lp = dbentry.lp
	attack = dbentry.attack
	defense = dbentry.defense
	accuracy = dbentry.accuracy
	evasion = dbentry.evasion
	
	if dbentry.support_type != VivoDBEntry.SUPPORT_TYPE.NONE:
		sattack = dbentry.sattack
		sdefense = dbentry.sdefense
		saccuracy = dbentry.saccuracy
		sevasion = dbentry.sevasion
	else:
		sattack = 0
		sdefense = 0
		saccuracy = 0
		sevasion = 0

func get_asset_path() -> String:
	match dbentry.gen:
		0: return "res://Assets/Vivosaur/"
		1: return "res://Assets/Vivosaur-Champions/"
		2: return "res://Assets/Vivosaur-ZestyZino/"
	return ""
