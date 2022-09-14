extends UIItem

class_name BattleVivo

var vivo:Vivosaur setget set_vivo
func set_vivo(new:Vivosaur):
	vivo = new
	if vivo != null:
		health = vivo.LP

var health:int setget set_health
func set_health(new:int):
	if vivo != null:
		new = int(clamp(new, 0, vivo.lp))
		health = new

var exhausted_turn:bool = false
var fainted:bool = false
var scare_restricted_skills:Array
var has_linked:bool = false

class StatusEffect extends Object:
	var effect:int
	var severity:int
	var turn_cnt:int
	var skip_first_check:bool

var status_effects:Array = []

func add_status_effect(effect:int, severity:int, skip_first_check:bool = false):
	var existing:StatusEffect = find_status_effect(effect)
	if existing != null:
		status_effects.erase(existing)
	
	var obj:StatusEffect = StatusEffect.new()
	obj.effect = effect
	obj.severity = severity
	obj.turn_cnt = 0
	obj.skip_first_check = skip_first_check
	status_effects.append(obj)
	
	if effect == Skill.STATUS_EFFECT.SCARE:
		generate_scare_restricted_skills()

func tick_status_effects() -> Array:
	var ret:Array = []
	for se in status_effects:
		if se.skip_first_check:
			se.skip_first_check = false
		else:
			se.turn_cnt += 1
			if se.turn_cnt >= Skill.get_status_turn_endurance(se.effect):
				ret.append(se)
	for se in ret:
		status_effects.erase(se)
	return ret

func find_status_effect(effect:int) -> StatusEffect:
	for se in status_effects:
		if se.effect == effect:
			return se
	return null

func has_status_effect(effect:int) -> bool:
	return find_status_effect(effect) != null

func generate_scare_restricted_skills():
	scare_restricted_skills.clear()
	for _i in range(vivo.dbentry.skills.size() / 2):
		while true:
			randomize()
			var skill:Skill = vivo.dbentry.skills[randi() % vivo.dbentry.skills.size()]
			if not scare_restricted_skills.has(skill):
				scare_restricted_skills.append(skill)
				break
