extends BattlePlayer

class_name AIPlayer

var artificial_delay:float = 1.0

func process_turn(enemy_team:BattleTeam, attack_cnt:int) -> BattleAction.Generic:
	var act:BattleAction.Generic
	
	var swap:bool = false
	var swap_sz2:bool = false
	
	if battle_team.can_swap():
		var swap_priority:bool = false
		
		if battle_team.az.exhausted_turn:
			var az_match:BattleAnalysis.Match = BattleAnalysis.bv_matchup(battle_team.az, battle_team, enemy_team.az, enemy_team)
			
			if az_match == null:
				swap_priority = true
			else:
				if not az_match.will_kill:
					if az_match.damage == -1:
						swap_priority = true
					elif attack_cnt > 0 and battle_team.az.has_status_effect(Skill.STATUS_EFFECT.POISON):
						swap_priority = true
		
		if swap_priority or BattleRules.element_match_bv(battle_team.az, enemy_team.az) != BattleRules.ELEMENT_MATCHUP.FAVORABLE:
			if not swap_priority:
				swap_priority = BattleRules.element_match_bv(battle_team.az, enemy_team.az) == BattleRules.ELEMENT_MATCHUP.UNFAVORABLE
			var bv_nomatchup:bool = false
			var sz2_nomatchup:bool = false
			
			for bv in [battle_team.sz1, battle_team.sz2]:
				if bv != null:
					var matchup:int = BattleRules.element_match_bv(bv, enemy_team.az)
					if bv.vivo.attack > battle_team.az.vivo.attack - 20:
						if matchup == BattleRules.ELEMENT_MATCHUP.FAVORABLE:
							swap = true
							break
						elif swap_priority and matchup == BattleRules.ELEMENT_MATCHUP.NONE:
							bv_nomatchup = true
							sz2_nomatchup = swap_sz2
				swap_sz2 = true
			
			if not swap and bv_nomatchup:
				swap_sz2 = sz2_nomatchup
				swap = true
	
	if swap:
		act = BattleAction.Swap.new()
		act.sz2 = swap_sz2
	else:
		var mat:BattleAnalysis.Match
		for bv in battle_team.get_avaliable():
			mat = choose_match(match_attack(bv, battle_team, enemy_team), mat)
		
		if mat != null:
			act = BattleAction.Move.new()
			act.acting = mat.bv
			act.recieving = [mat.en]
			act.skill = mat.skill
	
	yield(battle_team.get_tree().create_timer(artificial_delay), "timeout")
	
	return act

func match_attack(bv:BattleVivo, team:BattleTeam, enemy:BattleTeam) -> BattleAnalysis.Match:
	var ret:BattleAnalysis.Match
	for en in enemy.get_non_esc():
		ret = choose_match(BattleAnalysis.bv_matchup(bv, team, en as BattleVivo, enemy), ret)
	return ret

func choose_match(m1:BattleAnalysis.Match, m2:BattleAnalysis.Match) -> BattleAnalysis.Match:
	if m1 == null and m2 == null:
		return null
	if m1 != null and m2 == null:
		return m1
	if m1 == null and m2 != null:
		return m2
	
	if m1.will_kill:
		return m1
	if m2.will_kill:
		return m2
	
	if m2.damage > m1.damage:
		return m2
	return m1
