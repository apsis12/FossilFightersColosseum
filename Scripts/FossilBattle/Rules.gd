extends Node

class_name BattleRules

enum ELEMENT_MATCHUP {
	NONE,
	FAVORABLE,
	UNFAVORABLE,
}

const element_circle = [
	VivoDBEntry.ELEMENT.FIRE,
	VivoDBEntry.ELEMENT.EARTH,
	VivoDBEntry.ELEMENT.AIR,
	VivoDBEntry.ELEMENT.WATER,
]

static func element_match(elatt:int, eldef:int) -> int:
	if not elatt in element_circle or not eldef in element_circle:
		return ELEMENT_MATCHUP.NONE
	
	if eldef == wrapi(elatt + 1, 0, element_circle.size()):
		return ELEMENT_MATCHUP.FAVORABLE
	if eldef == wrapi(elatt - 1, 0, element_circle.size()):
		return ELEMENT_MATCHUP.UNFAVORABLE
	
	return ELEMENT_MATCHUP.NONE


static func element_match_bv(bvatt:BattleVivo, bvdef:BattleVivo) -> int:
	return element_match(bvatt.vivo.dbentry.element, bvdef.vivo.dbentry.element)


static func get_stat_se_adjusted(stat_val:int, supp_val:int) -> float:
	return (float(supp_val) / 100.0 + 1.0) * float(stat_val)


static func damage_formula(power:int, att_sup:int, def:int, def_sup:int, ele_adv:int, sz:bool, crit:bool = false, rand:bool = true) -> int:
	var damage:float = get_stat_se_adjusted(power, att_sup) - get_stat_se_adjusted(def, def_sup)
	
	match ele_adv:
		ELEMENT_MATCHUP.FAVORABLE:
			damage *= 1.5
		ELEMENT_MATCHUP.UNFAVORABLE:
			damage *= 0.75
	
	if sz:
		damage *= 0.75
	
	if rand:
		randomize()
		damage *= 0.95 + randf() * 0.1
	
	if crit:
		damage *= 1.5
	
	# rounds down
	return int(damage)


static func in_parting_blow(bv:BattleVivo) -> bool:
	return bv.vivo.dbentry.abilities.has(VivoDBEntry.ABILITY.PARTING_BLOW) and \
	bv.health <= bv.vivo.lp / 10


static func damage_formula_bv(skill:Skill, bvatt:BattleVivo, att_sup:int, bvdef:BattleVivo, def_sup:int, sz:bool, crit:bool = false, rand:bool = true) -> int:
	var damage:float = float(damage_formula(
		skill.power, 
		att_sup, 
		bvdef.vivo.defense,
		def_sup,
		element_match_bv(bvatt, bvdef),
		sz,
		crit,
		rand
	))
	
	for se in bvatt.status_effects:
		match se.effect:
			Skill.STATUS_EFFECT.ENFLAME, Skill.STATUS_EFFECT.ENRAGE:
				match se.severity:
					1: damage *= 1.3
					2: damage *= 1.6
	for se in bvdef.status_effects:
		match se.effect:
			Skill.STATUS_EFFECT.HARDEN:
				match se.severity:
					1: damage *= 0.7
					2: damage *= 0.4
	
	if in_parting_blow(bvatt):
		damage *= 1.5
	
	return int(damage)


static func hit_chance(accuracy:int, acc_supp:int, evasion:int, eva_supp:int) -> float:
	var chance:float = get_stat_se_adjusted(accuracy, acc_supp) - get_stat_se_adjusted(evasion, eva_supp)
	randomize()
	chance *= 0.5 + randf() * 0.5
	return chance


static func hit_chance_bv(bvatt:BattleVivo, acc_supp:int, bvdef:BattleVivo, eva_supp:int) -> float:
	var accuracy:int = bvatt.vivo.accuracy
	if in_parting_blow(bvatt):
		accuracy *= 2
	
	var chance:float = hit_chance(accuracy, acc_supp, bvdef.vivo.evasion, eva_supp)
	
	for se in bvatt.status_effects:
		match se.effect:
			Skill.STATUS_EFFECT.ENRAGE:
				match se.severity:
					1: chance -= 15.0
					2: chance -= 30.0
	for se in bvdef.status_effects:
		match se.effect:
			Skill.STATUS_EFFECT.QUICKEN:
				match se.severity:
					1: chance -= 30.0
					2: chance -= 50.0
	
	return chance


static func allowed_targets(skill:Skill, bv:BattleVivo, team:BattleTeam, enemy:BattleTeam) -> Array:
	match skill.target:
		Skill.TARGET.ENEMY:
			return [enemy.az] if team.is_sz(bv) else enemy.get_non_esc()
		Skill.TARGET.ALLY:
			match skill.effect:
				Skill.EFFECT.STATUS, \
				Skill.EFFECT.NEUTRALIZE:
					if team.is_az(bv):
						return []
					else:
						return [team.az]
				_:
					var arr:Array = team.get_non_esc()
					arr.erase(bv)
					return arr
		Skill.TARGET.TEAM:
			match skill.effect:
				Skill.EFFECT.STATUS, \
				Skill.EFFECT.NEUTRALIZE:
					return [team.az]
				_:
					return team.get_all_zones()
		Skill.TARGET.ALL_ENEMY:
			return [enemy.az]
		Skill.TARGET.ALL_TEAM:
			return [team.az]
	
	return []


static func can_use_team_skills(team:BattleTeam) -> bool:
	var bvs:Array = team.get_all_zones()
	
	if bvs.size() != 3:
		return false
	
	var elements:Array = []
	for bv in bvs:
		bv = bv as BattleVivo
		elements.append(bv.vivo.dbentry.element)
	
	if Util.array_is_uniform(elements):
		return true
	
	return false


static func can_use_skill(skill:Skill, bv:BattleVivo, team:BattleTeam) -> bool:
	if skill.fp > team.fp:
		return false
	if skill.shown_type == Skill.SKILL_TYPE.TEAM and not can_use_team_skills(team):
		return false
	if bv.has_status_effect(Skill.STATUS_EFFECT.SCARE) and bv.scare_restricted_skills.has(skill):
		return false
	
	return true


static func get_bv_team(bv:BattleVivo, team1:BattleTeam, team2:BattleTeam) -> BattleTeam:
	for team in [team1, team2]:
		if team.get_all_zones().has(bv):
			return team
	
	return null
