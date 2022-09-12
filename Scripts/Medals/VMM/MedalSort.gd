extends Object

class_name MedalSort

static func sort_index(a:DinoMedal, b:DinoMedal):
	return a.vivo.list_index < b.vivo.list_index

static func sort_name(a:DinoMedal, b:DinoMedal):
	var aname:String = a.vivo.dbentry.label
	var name_comp:Array = [aname, b.vivo.dbentry.label]
	name_comp.sort()
	return name_comp[0] == aname

static func __int_prop_sort(property:String, a:DinoMedal, b:DinoMedal):
	var ap:int = a.vivo.get(property)
	var bp:int = b.vivo.get(property)
	return ap > bp or (ap == bp and a.vivo.list_index < b.vivo.list_index)

static func sort_lp(a:DinoMedal, b:DinoMedal):
	return __int_prop_sort("lp", a, b)

static func sort_attack(a:DinoMedal, b:DinoMedal):
	return __int_prop_sort("attack", a, b)

static func sort_defense(a:DinoMedal, b:DinoMedal):
	return __int_prop_sort("defense", a, b)

static func sort_accuracy(a:DinoMedal, b:DinoMedal):
	return __int_prop_sort("accuracy", a, b)

static func sort_evasion(a:DinoMedal, b:DinoMedal):
	return __int_prop_sort("evasion", a, b)

static func __group_order(arr:Array, aindex:int, bindex:int, agroup:int, bgroup:int):
	var apos:int = arr.find(agroup)
	var bpos:int = arr.find(bgroup)
	return apos < bpos or (apos == bpos and aindex < bindex)

const ELEMENT_ORDER:Array = [VivoDBEntry.ELEMENT.FIRE, VivoDBEntry.ELEMENT.EARTH, VivoDBEntry.ELEMENT.AIR, VivoDBEntry.ELEMENT.WATER, VivoDBEntry.ELEMENT.NEUTRAL, VivoDBEntry.ELEMENT.LEGENDARY]

static func sort_element(a:DinoMedal, b:DinoMedal):
	return __group_order(ELEMENT_ORDER, a.vivo.list_index, b.vivo.list_index, a.vivo.dbentry.element, b.vivo.dbentry.element)

const TYPE_ORDER:Array = [VivoDBEntry.TYPE.ALL_AROUND, VivoDBEntry.TYPE.ATTACK, VivoDBEntry.TYPE.DEFENSE, VivoDBEntry.TYPE.SUPPORT, VivoDBEntry.TYPE.LONG_RANGE, VivoDBEntry.TYPE.TRANSFORMATION]

static func sort_type(a:DinoMedal, b:DinoMedal):
	return __group_order(TYPE_ORDER, a.vivo.list_index, b.vivo.list_index, a.vivo.dbentry.type, b.vivo.dbentry.type)

const SIZE_ORDER:Array = [VivoDBEntry.SIZE.TITANIC, VivoDBEntry.SIZE.LARGE, VivoDBEntry.SIZE.MEDIUM, VivoDBEntry.SIZE.SMALL]

static func sort_size(a:DinoMedal, b:DinoMedal):
	return __group_order(SIZE_ORDER, a.vivo.list_index, b.vivo.list_index, a.vivo.dbentry.size, b.vivo.dbentry.size)

const SUPPORT_TYPE_ORDER = [VivoDBEntry.SUPPORT_TYPE.OWN, VivoDBEntry.SUPPORT_TYPE.ENEMY, VivoDBEntry.SUPPORT_TYPE.NONE]

static func sort_support_type(a:DinoMedal, b:DinoMedal):
	return __group_order(SUPPORT_TYPE_ORDER, a.vivo.list_index, b.vivo.list_index, a.vivo.dbentry.support_type, b.vivo.dbentry.support_type)

static func sort_total_fp(a:DinoMedal, b:DinoMedal):
	var afp:int = 0
	var bfp:int = 0
	
	for iter in a.vivo.dbentry.skills:
		afp += iter.fp
	for iter in b.vivo.dbentry.skills:
		bfp += iter.fp
	
	return afp > bfp or (afp == bfp and a.vivo.list_index < b.vivo.list_index)
