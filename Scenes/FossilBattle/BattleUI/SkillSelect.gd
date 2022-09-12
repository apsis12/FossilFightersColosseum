extends Node2D

func _ready():
	$FFWindow.push_predefined(FFMenu.PROFILES.BATTLE)
	$FFWindow.anchor = FFMenu.anchor_type.TOP

func push_skills(arr:Array, bv:BattleVivo, team:BattleTeam) -> Array:
	show()
	var team_skills:bool = BattleRules.can_use_team_skills(team)
	var nodes:Array = []
	for i in range(5):
		var item:UIItem = get_node("FFWindow/FossilBattleSkill" + str(i))
		if i < arr.size():
			item.skill = arr[i]
			if bv.has_status_effect(Skill.STATUS_EFFECT.SCARE) and bv.scare_restricted_skills.has(item.skill):
				item.modulate = Color("aa8899")
			elif item.skill.shown_type == Skill.SKILL_TYPE.TEAM and not team_skills:
				item.modulate = Color("555555")
			elif item.skill.fp > team.fp:
				item.modulate = Color("888888")
			else:
				item.modulate = Color.white
			nodes.append(item)
		item.hide()
	
	$FFWindow.set_target_size(Vector2(200, nodes.size() * 23), 0.175)
	yield($FFWindow, "transition_completed")
	for iter in nodes:
		iter.show()
	
	return nodes

func retreat_skills():
	for i in range(5):
		var item:UIItem = get_node("FFWindow/FossilBattleSkill" + str(i))
		item.hide()
	$FFWindow.target_size = Vector2.ZERO
	yield($FFWindow, "transition_completed")
	hide()
