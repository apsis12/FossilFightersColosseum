extends Node2D

const stat_normal_theme:Theme = preload("res://Fonts/Resource/FFStatNumbers.tres")
const stat_positive_theme:Theme = preload("res://Fonts/Resource/FFStatNumbersPositive.tres")
const stat_negative_theme:Theme = preload("res://Fonts/Resource/FFStatNumbersNegative.tres")

func set_bv(bv:BattleVivo, az:bool, mods:PoolIntArray):
	$Background.texture = preload("res://Assets/Battle/panels/vivo_info_battle.png")
	for iter in  $Background.get_children():
		if iter is Node2D:
			iter.visible = iter == $Background/Vivo
	
	$Background/Vivo/Label.text = bv.vivo.dbentry.label
	$Background/Vivo/Health.text = str(bv.health) + "/" + str(bv.vivo.dbentry.lp)
	
	if az:
		var nodes:Array = [$Background/Vivo/Attack, $Background/Vivo/Defense, $Background/Vivo/Accuracy, $Background/Vivo/Evasion]
		var stats:Array = bv.vivo.get_stats()
		stats.pop_front()
		for i in range(4):
			var text_temp:String = str(int(BattleRules.get_stat_se_adjusted(stats[i], mods[i])))
			
			if mods[i] > 0:
				nodes[i].theme = stat_positive_theme
				text_temp += "+"
			elif mods[i] < 0:
				nodes[i].theme = stat_negative_theme
				text_temp += "-"
			else:
				nodes[i].theme = stat_normal_theme
			
			nodes[i].text = text_temp
	else:
		$Background/Vivo/Attack.text = str(bv.vivo.attack)
		$Background/Vivo/Attack.theme = stat_normal_theme
		$Background/Vivo/Defense.text = str(bv.vivo.defense)
		$Background/Vivo/Defense.theme = stat_normal_theme
		$Background/Vivo/Accuracy.text = str(bv.vivo.accuracy)
		$Background/Vivo/Accuracy.theme = stat_normal_theme
		$Background/Vivo/Evasion.text = str(bv.vivo.evasion)
		$Background/Vivo/Evasion.theme = stat_normal_theme

func set_skill(skill:Skill):
	$Background.texture = preload("res://Assets/Battle/panels/vivo_info_blank.png")
	for iter in $Background.get_children():
		if iter is Node2D:
			iter.visible = iter == $Background/Skill
	
	$Background/Skill/Label.text = skill.label
	$Background/Skill/Power.text = "Power: " + str(skill.power)
	$Background/Skill/Chance.text = str(skill.effect_chance * 100) + "% Chance"
	if skill.effect == Skill.EFFECT.STATUS:
		$Background/Skill/Effect.text = Skill.str_status(skill.status_effect).capitalize()
	elif skill.effect != Skill.EFFECT.NONE:
		$Background/Skill/Effect.text = Skill.str_effect(skill.effect).capitalize()
	else:
		$Background/Skill/Effect.text = "---"
		$Background/Skill/Chance.text = "---"
	$Background/Skill/Target.text = "Target: " + Skill.str_target(skill.target).capitalize()
