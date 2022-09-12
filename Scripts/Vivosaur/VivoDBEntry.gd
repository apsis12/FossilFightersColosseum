extends Object

class_name VivoDBEntry


var index:int

var label:String
var gen:int
var element:int
var type:int
var size:int
var rnge:int
var super_evolver:bool

var description:String

var lp:int
var attack:int
var defense:int
var accuracy:int
var evasion:int

var support_type:int
var sattack:int
var sdefense:int
var saccuracy:int
var sevasion:int

var crit_rate:float

var abilities:PoolIntArray

var fossil_museum_description:String
var genus:String
var group:String
var diet:String
var era:String
var discovered:PoolStringArray
var dig_site:String

var proper_name:String
var fav_food:String
var fav_place:String
var likes:String
var human_age:String
var model_name:String
var power_source:String
var warranty_period:String

var skills:Array


enum ELEMENT {
	FIRE = 0,
	EARTH = 1,
	AIR = 2,
	WATER = 3,
	NEUTRAL,
	LEGENDARY,
}

static func str_element(inp:int) -> String:
	match inp:
		ELEMENT.FIRE: return "fire"
		ELEMENT.EARTH: return "earth"
		ELEMENT.AIR: return "air"
		ELEMENT.WATER: return "water"
		ELEMENT.NEUTRAL: return "neutral"
		ELEMENT.LEGENDARY: return "legendary"
	assert(false)
	return ""

static func element_to_color(inp:int) -> Color:
	match inp:
		ELEMENT.FIRE: return Color("f75239")
		ELEMENT.NEUTRAL: return Color.whitesmoke
		ELEMENT.WATER: return Color("1884de")
		ELEMENT.AIR: return Color("08c64a")
		ELEMENT.EARTH: return Color("ef8c10")
		ELEMENT.LEGENDARY: return Color("485058")
	assert(false)
	return Color.white


enum TYPE {
	ATTACK,
	ALL_AROUND,
	SUPPORT,
	DEFENSE,
	LONG_RANGE,
	TRANSFORMATION,
}

static func str_type(inp:int) -> String:
	match inp:
		TYPE.ATTACK: return "attack"
		TYPE.ALL_AROUND: return "all-around"
		TYPE.SUPPORT: return "support"
		TYPE.DEFENSE: return "defense"
		TYPE.LONG_RANGE: return "long-range"
		TYPE.TRANSFORMATION: return "transformation"
	assert(false)
	return ""

enum SIZE {
	SMALL,
	MEDIUM,
	LARGE,
	TITANIC,
}

static func str_size(inp:int) -> String:
	match inp:
		SIZE.SMALL: return "small"
		SIZE.MEDIUM: return "medium"
		SIZE.LARGE: return "large"
		SIZE.TITANIC: return "titanic"
	assert(false)
	return ""


enum RANGE {
	CLOSE,
	MID,
	LONG,
}

static func str_range(inp:int) -> String:
	match inp:
		RANGE.CLOSE: return "close"
		RANGE.MID: return "mid"
		RANGE.LONG: return "long"
	assert(false)
	return ""

enum SUPPORT_TYPE {
	OWN,
	ENEMY,
	NONE,
}

static func str_support_type(inp:int) -> String:
	match inp:
		SUPPORT_TYPE.OWN: return "own"
		SUPPORT_TYPE.ENEMY: return "enemy"
		SUPPORT_TYPE.NONE: return "none"
	assert(false)
	return ""

enum ABILITY {
	AUTO_COUNTER,
	FP_PLUS,
	PARTING_BLOW,
	AUTO_LP_RECOVERY,
	LINK,
}

static func str_ability(inp:int) -> String:
	match inp:
		ABILITY.AUTO_COUNTER: return "auto counter"
		ABILITY.FP_PLUS: return "fp plus"
		ABILITY.PARTING_BLOW: return "parting blow"
		ABILITY.AUTO_LP_RECOVERY: return "auto lp recovery"
		ABILITY.FP_ABSORB: return "fp absorb"
		ABILITY.LINK: return "link"
	assert(false)
	return ""


func import(meta_entry:Dictionary, skill_lookup:Dictionary):
	index = meta_entry["Index"]
	label = meta_entry["Name"]
	
	gen = meta_entry["Generation"]
	assert(gen >= 0 and gen <= 2)
	
	match meta_entry["Element"]:
		"Fire": element = ELEMENT.FIRE
		"Earth": element = ELEMENT.EARTH
		"Water": element = ELEMENT.WATER
		"Air": element = ELEMENT.AIR
		"Neutral": element = ELEMENT.NEUTRAL
		"Legendary": element = ELEMENT.LEGENDARY
		_: assert(false)
	
	match meta_entry["Type"]:
		"Attack": type = TYPE.ATTACK
		"All-Around": type = TYPE.ALL_AROUND
		"Support": type = TYPE.SUPPORT
		"Defensive": type = TYPE.DEFENSE
		"Long-Range": type = TYPE.LONG_RANGE
		"Transformation": type = TYPE.TRANSFORMATION
		_: assert(false)
	
	match meta_entry["Size"]:
		"Small": size = SIZE.SMALL
		"Medium": size = SIZE.MEDIUM
		"Large": size = SIZE.LARGE
		"Titanic": size = SIZE.TITANIC
		_: assert(false)
	
	match meta_entry["Range"]:
		"Close": rnge = RANGE.CLOSE
		"Mid": rnge = RANGE.MID
		"Long": rnge = RANGE.LONG
		_: assert(false)
	
	super_evolver = meta_entry["Super Evolver"] != null
	
	description = meta_entry["Description"]
	
	lp = meta_entry["LP"]
	attack = meta_entry["Attack"]
	defense = meta_entry["Defense"]
	accuracy = meta_entry["Accuracy"]
	evasion = meta_entry["Evasion"]
	
	match meta_entry["SupportType"]:
		"Own": support_type = SUPPORT_TYPE.OWN
		"Enemy": support_type = SUPPORT_TYPE.ENEMY
		_: support_type = SUPPORT_TYPE.NONE
	
	if support_type != SUPPORT_TYPE.NONE:
		sattack = meta_entry["SAttack"]
		sdefense = meta_entry["SDefense"]
		saccuracy = meta_entry["SAccuracy"]
		sevasion = meta_entry["SEvasion"] 
	
	if meta_entry["Crit Rate"] != null:
		crit_rate = meta_entry["Crit Rate"]
	else:
		crit_rate = 0
	
	abilities.resize(0)
	for key in PoolStringArray(["Ability1", "Ability2"]):
		match meta_entry[key]:
			"Auto Counter": abilities.append(ABILITY.AUTO_COUNTER)
			"FP Plus": abilities.append(ABILITY.FP_PLUS)
			"Parting Blow": abilities.append(ABILITY.PARTING_BLOW)
			"Auto LP Recovery": abilities.append(ABILITY.AUTO_LP_RECOVERY)
			"Link": abilities.append(ABILITY.LINK)
	
	fossil_museum_description = meta_entry["Fossil Museum"]
	if meta_entry["Genus"] != null:
		genus = meta_entry["Genus"]
	if meta_entry["Diet"] != null:
		diet = meta_entry["Diet"]
	if meta_entry["Era"] != null:
		era = meta_entry["Era"]
	
	for key in PoolStringArray(["Discovered1", "Discovered2"]):
		if meta_entry[key] != null:
			discovered.append(meta_entry[key])
	
	if meta_entry["Dig Site"] != null:
		dig_site = meta_entry["Dig Site"]
	
	if meta_entry["Proper Name"] != null:
		proper_name = meta_entry["Proper Name"]
	if meta_entry["Favorite Food"] != null:
		fav_food = meta_entry["Favorite Food"]
	if meta_entry["Favorite Place"] != null:
		fav_place = meta_entry["Favorite Place"]
	if meta_entry["Likes"] != null:
		likes = meta_entry["Likes"]
	if meta_entry["Human Age"] != null:
		human_age = str(meta_entry["Human Age"])
	if meta_entry["Model Name"] != null:
		model_name = meta_entry["Model Name"]
	if meta_entry["Power Source"] != null:
		power_source = meta_entry["Power Source"]
	if meta_entry["Warranty Period"] != null:
		warranty_period = meta_entry["Warranty Period"]
	
	skills.resize(0)
	for iter in skill_lookup[label] as Array:
		var skill = Skill.new()
		skill.import(iter)
		skills.append(skill)
