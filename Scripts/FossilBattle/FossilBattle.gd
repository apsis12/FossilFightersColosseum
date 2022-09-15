extends Node2D

class_name FossilBattle

# Q: Why are there so many instances of checking if a return value is a function state?
# A: There doesn't seem to be another way to efficiently wait for a function to finish
#    if it calls yield() or continue when it doesn't. Since this class expects both to be run in a
#    headless state or for animations to occur between critical code, this behavior is necessary.

# Nodes #################
var player_1:BattlePlayer
var player_2:BattlePlayer
#########################

var attacking:BattlePlayer
var defending:BattlePlayer

func message(msg:String):
	print(msg)

func get_both_teams() -> Array:
	return [attacking.battle_team, defending.battle_team]

func get_other_team(team:BattleTeam) -> BattleTeam:
	match team:
		attacking.battle_team:
			return defending.battle_team
		defending.battle_team:
			return attacking.battle_team
	return null

func get_all_avaliable_bvs() -> Array:
	return attacking.battle_team.get_avaliable() + defending.battle_team.get_avaliable()
func get_all_non_esc_bvs():
	return attacking.battle_team.get_non_esc() + defending.battle_team.get_non_esc()

func switch():
	var old_def:BattlePlayer = defending
	defending = attacking
	attacking = old_def

func compare_lp() -> bool:
	# returns true if team 1 's lp is greater
	
	var lp1:int = player_1.battle_team.team.get_total_lp()
	var lp2:int = player_2.battle_team.team.get_total_lp()
	
	return lp1 >= lp2


func apply_bv_stat_mods(bv:BattleVivo, team:BattleTeam, remove:bool = false):
	var which:BattleTeam
	match bv.vivo.dbentry.support_type:
		VivoDBEntry.SUPPORT_TYPE.OWN:
			which = team
		VivoDBEntry.SUPPORT_TYPE.ENEMY:
			which = get_other_team(team)
		_:
			return
	
	if remove:
		team.se_applied_bvs.erase(bv)
		which.az_mods = Util.sub_pia(which.az_mods, bv.vivo.get_support_effects())
	else:
		team.se_applied_bvs.append(bv)
		which.az_mods = Util.add_pia(which.az_mods_indicator.mods, bv.vivo.get_support_effects())
	
	var tmp = Util.hook(self, "apply_se_hook", [bv, which, remove])
	if tmp is GDScriptFunctionState: yield(tmp, "completed")

func remove_bv_mods(bv:BattleVivo, team:BattleTeam):
	if team.se_applied_bvs.has(bv):
		var tmp = apply_bv_stat_mods(bv, team, true)
		if tmp is GDScriptFunctionState: yield(tmp, "completed")

func remove_all_mods(team:BattleTeam):
	var applied_list:Array = team.se_applied_bvs.duplicate()
	for bv in applied_list:
		if bv.vivo.dbentry.support_type == VivoDBEntry.SUPPORT_TYPE.OWN:
			var tmp = remove_bv_mods(bv, team)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	var enemy:BattleTeam = get_other_team(team)
	applied_list = enemy.se_applied_bvs.duplicate()
	for bv in applied_list:
		if bv.vivo.dbentry.support_type == VivoDBEntry.SUPPORT_TYPE.ENEMY:
			var tmp = remove_bv_mods(bv, enemy)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")

func check_bv_mods(team:BattleTeam):
	for bv in team.get_sz():
		if not team.se_applied_bvs.has(bv):
			var tmp = apply_bv_stat_mods(bv, team)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")

func move_zone_team(team:BattleTeam, zones:Array):
	var tmp
	for zone in zones:
		if zone == BattleTeam.ZONE_AZ:
			tmp = remove_all_mods(team)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
			break
		else:
			tmp = remove_bv_mods(team.get_zone(zone), team)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
	tmp = Util.hook(self, "move_zone_hook", [team, zones])
	if tmp is GDScriptFunctionState: yield(tmp, "completed")

func remove_all_status_effects(bv:BattleVivo):
	if bv.status_effects.size() != 0:
		var status_effects:Array = bv.status_effects.duplicate()
		bv.status_effects.clear()
		
		var msg:String = "No longer:"
		for se in status_effects:
			msg += " " + Skill.str_status_adj(se.effect)
		message(msg)
		
		var tmp = Util.hook(self, "remove_status_effect_hook", [bv, status_effects])
		if tmp is GDScriptFunctionState: yield(tmp, "completed")

func swap_out_team(team:BattleTeam):
	var tmp = remove_all_status_effects(team.esc)
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	tmp = move_zone_team(team, [BattleTeam.ZONE_AZ, BattleTeam.ZONE_ESC])
	if tmp is GDScriptFunctionState: yield(tmp, "completed")

func faint_bv(bv:BattleVivo, team:BattleTeam):
	team.faint(bv)
	var fp_add:int = bv.vivo.lp / 2
	team.fp += fp_add
	message(bv.vivo.dbentry.label + " was defeated!")
	var tmp = remove_bv_mods(bv, team)
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	tmp = Util.hook(self, "change_fp_hook", [team, fp_add])
	if tmp is GDScriptFunctionState: yield(tmp, "completed")

func change_health(bv:BattleVivo, team:BattleTeam, dlp:int, hook:bool = true) -> bool:
	bv.health += dlp
	var faint:bool = bv.health == 0
	
	if hook:
		var tmp = Util.hook(self, "alter_health_hook", [bv, team, dlp, faint])
		if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	return faint

func exec_action(action:BattleAction.Generic, restrict_consequences:bool = false) -> bool:
	var tmp
	if action == null:
		return true
	
	var confused:bool = false
	if action is BattleAction.Move and \
	not attacking.battle_team.az.exhausted_turn and \
	attacking.battle_team.az.has_status_effect(Skill.STATUS_EFFECT.CONFUSE):
		confused = true
		var new_action:BattleAction.Generic
		var new_skill:int = BattleRules.random_skill(attacking.battle_team.az, attacking.battle_team)
		if new_skill == -1:
			new_action = BattleAction.Swap.new()
		else:
			var receiving = Util.array_random(BattleRules.allowed_targets(attacking.battle_team.az.vivo.dbentry.skills[new_skill], attacking.battle_team.az, attacking.battle_team, defending.battle_team))
			if (receiving is Array and receiving.size() > 0) or (receiving != null):
				new_action = BattleAction.Move.new()
				new_action.acting = attacking.battle_team.az
				new_action.recieving = [receiving]
				new_action.skill = new_skill
			else:
				new_action = BattleAction.Swap.new()
		action = new_action
		message(attacking.battle_team.az.vivo.dbentry.label + " is confused!")
	
	if action is BattleAction.Move:
		assert(action.acting in attacking.battle_team.get_all_zones(), "Invalid vivo")
		assert(not action.acting.exhausted_turn, "Vivo has spent turn")
		
		var skill:Skill = action.acting.vivo.dbentry.skills[action.skill]
		if not restrict_consequences:
			assert(BattleRules.can_use_skill(skill, action.acting, attacking.battle_team), "Cannot use skill")
		
		if not restrict_consequences:
			action.acting.exhausted_turn = true
			attacking.battle_team.fp -= skill.fp
			tmp = Util.hook(self, "change_fp_hook", [attacking.battle_team, -skill.fp])
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
		
		match skill.target:
			Skill.TARGET.ALL_ENEMY:
				action.recieving = defending.battle_team.get_non_esc()
			Skill.TARGET.ALL_TEAM:
				action.recieving = attacking.battle_team.get_non_esc()
		
		tmp = Util.hook(self, "start_move_hook", [action])
		if tmp is GDScriptFunctionState: yield(tmp, "completed")
		
		if skill.type == Skill.SKILL_TYPE.ATTACK:
			if BattleRules.in_parting_blow(action.acting):
				message("Activating Parting Blow!")
				tmp = Util.hook(self, "activate_ability_hook", [[action.acting], true])
				if tmp is GDScriptFunctionState: yield(tmp, "completed")
		
		var recieving_effects:Array = []
		var landed:bool = true
		var faint_acting:bool = false
		
		for target in action.recieving:
			target = target as BattleVivo
			var faint:bool = false
			
			match skill.type:
				Skill.SKILL_TYPE.ATTACK:
					var hit_chance:float = BattleRules.hit_chance_bv(action.acting, attacking.battle_team.az_mods[2], target, defending.battle_team.az_mods[3])
					landed = hit_chance > 0
					
					if landed:
						var crit:bool = false
						if BattleSettings.allow_crits:
							randomize()
							crit = randf() <= action.acting.vivo.get_crit_rate()
						
						var damage:int = 0
						if skill.power > 0:
							damage = \
								BattleRules.damage_formula_bv (
									skill,
									action.acting,
									attacking.battle_team.az_mods[0] if attacking.battle_team.is_az(action.acting.vivo) else 0,
									target,
									defending.battle_team.az_mods[1],
									
									(attacking.battle_team.is_sz(action.acting) or \
									defending.battle_team.is_sz(target)) and \
									action.acting.vivo.dbentry.type != VivoDBEntry.TYPE.LONG_RANGE,
									
									crit
								)
						
						message("Critical hit: delivered " + str(damage) + " damage" if crit else "Delivered " + str(damage) + " damage.")
# warning-ignore:function_may_yield
						faint = change_health(target, null, -damage, false)
						
						if skill.effect == Skill.EFFECT.KAMIKAZE:
							message(action.acting.vivo.dbentry.label + " exchanged its LP for extra damage!")
							if action.acting.health > 0:
								tmp = change_health(action.acting, attacking.battle_team, -action.acting.health+1)
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
						
						tmp = Util.hook(self, "hit_hook", [action, target, skill, damage, crit, faint])
						if tmp is GDScriptFunctionState: yield(tmp, "completed")
						
						if damage > 0:
							if not faint_acting:
								if target.vivo.dbentry.abilities.has(VivoDBEntry.ABILITY.AUTO_COUNTER):
									message("Activating Auto Counter!")
									
									tmp = Util.hook(self, "activate_ability_hook", [[target], true])
									if tmp is GDScriptFunctionState: yield(tmp, "completed")
									
									tmp = change_health(action.acting, attacking.battle_team, -damage / 10)
									if tmp is GDScriptFunctionState: tmp = yield(tmp, "completed")
									if tmp as bool:
										faint_acting = true
							
							if not faint_acting:
								var counter:BattleVivo.StatusEffect = target.find_status_effect(Skill.STATUS_EFFECT.COUNTER)
								if counter != null:
									randomize()
									if randf() <= float(counter.severity) / 100.0:
										message("Countered!")
										tmp = change_health(action.acting, attacking.battle_team, -damage)
										if tmp is GDScriptFunctionState: tmp = yield(tmp, "completed")
										if tmp as bool:
											faint_acting = true
					else:
						message("The attack missed!")
						tmp = Util.hook(self, "miss_hook", [action, target, skill])
						if tmp is GDScriptFunctionState: yield(tmp, "completed")
				
				Skill.SKILL_TYPE.SPECIAL:
					pass
			
			if faint:
				tmp = faint_bv(target, defending.battle_team)
				if tmp is GDScriptFunctionState: yield(tmp, "completed")
			else:
				recieving_effects.append(target)
		
		if faint_acting:
			tmp = faint_bv(action.acting, attacking.battle_team)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
		
		if landed and recieving_effects.size() > 0:
			if skill.effect != Skill.EFFECT.NONE:
				randomize()
				if skill.effect_chance == 1 or randf() <= skill.effect_chance:
					match skill.effect:
						Skill.EFFECT.STATUS: 
							for target in recieving_effects:
								var team:BattleTeam = BattleRules.get_bv_team(target, attacking.battle_team, defending.battle_team)
								if team.is_az(target):
									target.add_status_effect(skill.status_effect, skill.effect_severity, team == attacking.battle_team)
									message(target.vivo.dbentry.label + " " + Skill.str_status_sentence(skill.status_effect) + "!")
									tmp = Util.hook(self, "add_status_effect_hook", [target])
									if tmp is GDScriptFunctionState: yield(tmp, "completed")
									break
						Skill.EFFECT.LAW_OF_THE_JUNGLE:
							var target:BattleVivo = recieving_effects[0]
							var health_exchange:int = target.health - 1 if target.health > 0 else 0
							tmp = change_health(target, BattleRules.get_bv_team(target, attacking.battle_team, defending.battle_team), -health_exchange)
							if tmp is GDScriptFunctionState: yield(tmp, "completed")
							message(action.acting.vivo.dbentry.label + " stole " + str(health_exchange) + " lp from ally " + target.vivo.dbentry.label)
							tmp = change_health(action.acting, attacking.battle_team, health_exchange)
							if tmp is GDScriptFunctionState: yield(tmp, "completed")
						Skill.EFFECT.SACRIFICE:
							var target:BattleVivo = recieving_effects[0]
							var health_exchange:int = action.acting.health - 1 if target.health > 0 else 0
							tmp = change_health(action.acting, attacking.battle_team, -health_exchange)
							if tmp is GDScriptFunctionState: yield(tmp, "completed")
							tmp = change_health(target, BattleRules.get_bv_team(target, attacking.battle_team, defending.battle_team), health_exchange)
							if tmp is GDScriptFunctionState: yield(tmp, "completed")
						Skill.EFFECT.FP_EQUALIZE:
							var average_fp:int = (attacking.battle_team.fp + defending.battle_team.fp) / 2
							for team in get_both_teams():
								var last:int = team.fp
								team.fp = average_fp
								tmp = Util.hook(self, "change_fp_hook", [team, -(last - team.fp)])
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
							message("FP Equalized!")
						Skill.EFFECT.KNOCK:
							for target in recieving_effects: 
								if BattleRules.get_bv_team(target, attacking.battle_team, defending.battle_team).is_az(target):
									if defending.battle_team.force_swap_out():
										tmp = swap_out_team(defending.battle_team)
										message(defending.battle_team.esc.vivo.dbentry.label + " was knocked to the SZ!")
										if tmp is GDScriptFunctionState: yield(tmp, "completed")
										break
						Skill.EFFECT.HEAL:
							for target in recieving_effects:
								message(target.vivo.dbentry.label + " was healed!")
								tmp = change_health(target, BattleRules.get_bv_team(target, attacking.battle_team, defending.battle_team), skill.effect_severity)
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
						Skill.EFFECT.STEAL_FP:
							var stolen_fp:int = int(min(skill.effect_severity, defending.battle_team.fp))
							if stolen_fp > 0:
								defending.battle_team.fp -= stolen_fp
								attacking.battle_team.fp += stolen_fp
								message("Stole " + str(stolen_fp) + " FP!")
								tmp = Util.hook(self, "change_fp_hook", [defending.battle_team, -stolen_fp])
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
								tmp = Util.hook(self, "change_fp_hook", [attacking.battle_team, stolen_fp])
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
						Skill.EFFECT.NEUTRALIZE:
							var target:BattleVivo = recieving_effects[0]
							if BattleRules.get_bv_team(target, attacking.battle_team, defending.battle_team).is_az(target):
								tmp = remove_all_status_effects(target)
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
						Skill.EFFECT.DISPLACE:
							if defending.battle_team.az != null:
								tmp = remove_all_status_effects(defending.battle_team.az)
								if tmp is GDScriptFunctionState: yield(tmp, "completed")
							tmp = move_zone_team(defending.battle_team, defending.battle_team.displace())
							message("The defending team was displaced!")
							if tmp is GDScriptFunctionState: yield(tmp, "completed")
						Skill.EFFECT.TRANSFORM:
							# not implemented yet
							pass
			
			if attacking.battle_team.is_az(action.acting) and \
			skill.type == Skill.SKILL_TYPE.ATTACK and \
			skill.target == Skill.TARGET.ENEMY:
				for bv in attacking.battle_team.get_avaliable():
					bv = bv as BattleVivo
					if bv.vivo.dbentry.abilities.has(VivoDBEntry.ABILITY.LINK) and not bv.has_linked:
						bv.has_linked = true
						
						var link_action:BattleAction.Move = BattleAction.Move.new()
						link_action.acting = bv
						link_action.recieving = [recieving_effects[0]]
						link_action.skill = 0
						
						message("Activating Link!")
						tmp = Util.hook(self, "activate_ability_hook", [[link_action.acting], true])
						if tmp is GDScriptFunctionState: yield(tmp, "completed")
						
						tmp = exec_action(link_action, true)
						if tmp is GDScriptFunctionState: yield(tmp, "completed")
		
		tmp = Util.hook(self, "end_move_hook", [action])
		if tmp is GDScriptFunctionState: yield(tmp, "completed")
		
	elif action is BattleAction.Swap:
		var success:bool = false
		if not attacking.battle_team.swap_out(action.sz2):
			success = attacking.battle_team.swap_out(not action.sz2)
		else:
			success = true
		if success:
			tmp = swap_out_team(attacking.battle_team)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	return false

func turn() -> BattlePlayer:
	var tmp
	
	attacking.battle_team.reset()
	defending.battle_team.reset()
	
	tmp = Util.hook(self, "beginning_of_turn_hook")
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	var fp_add:int = attacking.fp_per_turn
	var fp_plus_bvs:Array = []
	for bv in attacking.battle_team.get_non_esc():
		bv = bv as BattleVivo
		if bv.vivo.dbentry.abilities.has(VivoDBEntry.ABILITY.FP_PLUS):
			fp_add += attacking.fp_per_turn / 5
			fp_plus_bvs.append(bv)
	if fp_plus_bvs.size() > 0:
		message("Activating FP Plus")
		tmp = Util.hook(self, "activate_ability_hook", [fp_plus_bvs, false])
		if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	attacking.battle_team.fp += fp_add
	tmp = Util.hook(self, "change_fp_hook", [attacking.battle_team, fp_add])
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	tmp = check_bv_mods(attacking.battle_team)
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	for bv in attacking.battle_team.get_all_zones():
		bv = bv as BattleVivo
		if bv.vivo.dbentry.abilities.has(VivoDBEntry.ABILITY.AUTO_LP_RECOVERY):
			tmp = change_health(bv, attacking.battle_team, bv.vivo.lp / 20)
			if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	var attack_cnt:int = 0
	while true:
		var action = attacking.process_turn(defending.battle_team, attack_cnt)
		if action is GDScriptFunctionState: action = yield(action, "completed")
		action = action as BattleAction.Generic
		
		if action is BattleAction.Move:
			attack_cnt += 1
		
		var end_turn = exec_action(action)
		if end_turn is GDScriptFunctionState: end_turn = yield(end_turn, "completed")
		
		for player in [attacking, defending]:
			if player.battle_team.is_defeated():
				return player
		
		if end_turn:
			break
		
		for team in get_both_teams():
			if team.assume_az():
				tmp = move_zone_team(team, [BattleTeam.ZONE_AZ])
				if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	tmp = Util.hook(self, "end_of_actions_hook")
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	var completed:Array =  attacking.battle_team.az.tick_status_effects()
	var faint = false
	for se in completed:
		if se.effect == Skill.STATUS_EFFECT.POISON:
			var divisor:int
			match se.severity:
				1: divisor = 8
				2: divisor = 6
				3: divisor = 4
			faint = change_health(attacking.battle_team.az, attacking.battle_team, -attacking.battle_team.az.vivo.dbentry.lp / divisor)
			if faint is GDScriptFunctionState: faint = yield(faint, "completed")
			if faint:
				tmp = faint_bv(attacking.battle_team.az, attacking.battle_team)
				if tmp is GDScriptFunctionState: yield(tmp, "completed")
				if attacking.battle_team.assume_az():
					tmp = move_zone_team(attacking.battle_team, [BattleTeam.ZONE_AZ])
					if tmp is GDScriptFunctionState: yield(tmp, "completed")
				break
	
	if completed.size() > 0:
		var msg:String = "No longer:"
		for se in completed:
			msg += " " + Skill.str_status_adj(se.effect)
		message(msg)
		tmp = Util.hook(self, "remove_status_effect_hook", [attacking.battle_team.az, completed])
		if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	if attacking.battle_team.esc != null:
		attacking.battle_team.esc_turn_cnt += 1
		if attacking.battle_team.esc_turn_cnt > 1:
			var loc:int = attacking.battle_team.unescape()
			if loc != -1:
				attacking.battle_team.esc_turn_cnt = 0
				tmp = move_zone_team(attacking.battle_team, [loc])
				if tmp is GDScriptFunctionState: yield(tmp, "completed")
	else:
		attacking.battle_team.esc_turn_cnt = 0
	
	tmp = Util.hook(self, "end_of_turn_hook")
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	return null

func battle_init():
	var tmp
	
	attacking = player_1
	defending = player_2
	
	tmp = Util.hook(self, "battle_init_hook")
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	for team in get_both_teams():
		tmp = check_bv_mods(team)
		if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	tmp = Util.hook(self, "battle_after_init_hook")
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	if compare_lp():
		switch()
	
	var winner
	
	while true:
		winner = yield(turn(), "completed")
		if winner is GDScriptFunctionState: winner = yield(winner, "completed")
		if winner != null:
			break
		switch()
	
	tmp = Util.hook(self, "battle_end_hook", [winner])
	if tmp is GDScriptFunctionState: yield(tmp, "completed")
	
	print("Battle Ended!")
