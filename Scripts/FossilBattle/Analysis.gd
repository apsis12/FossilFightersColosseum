extends Object

class_name BattleAnalysis

class Match:
	var bv:BattleVivo
	var en:BattleVivo
	
	var skill:int = -1
	var damage:int = -1
	var will_kill:bool = false

static func bv_matchup(bvatt:BattleVivo, teamatt:BattleTeam, bvdef:BattleVivo, teamdef:BattleTeam) -> Match:
	if teamatt.is_sz(bvatt) and teamdef.is_sz(bvdef):
		return null
	
	var ret:Match = Match.new()
	
	var cnt:int = 0
	for skill in bvatt.vivo.dbentry.skills:
		if skill.type == Skill.SKILL_TYPE.ATTACK and \
		skill.target == Skill.TARGET.ENEMY and \
		skill.power != 0 and \
		BattleRules.can_use_skill(skill, bvatt, teamatt):
			var dam:int = \
				BattleRules.damage_formula_bv(
					skill,
					bvatt,
					teamatt.get_az_mod_attack(),
					bvdef,
					teamdef.get_az_mod_defense(),
					teamatt.is_sz(bvatt) or teamdef.is_sz(bvdef)
				)
			if dam > ret.damage:
				ret.skill = cnt
				ret.damage = dam
		cnt += 1
	
	if ret.skill == -1:
		return null
	
	ret.bv = bvatt
	ret.en = bvdef
	ret.will_kill = ret.damage >= bvdef.health
	
	return ret
