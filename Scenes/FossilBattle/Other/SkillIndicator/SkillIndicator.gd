extends Node2D

func show_skill(skill:Skill):
	$FossilBattleSkill.skill = skill
	$Tween.interpolate_property($FossilBattleSkill, "position:y", 0, -30, 0.2, Tween.TRANS_QUINT)
	$Tween.start()

func retreat():
	$Tween.interpolate_property($FossilBattleSkill, "position:y", -30, 0, 0.2, Tween.TRANS_QUINT)
	$Tween.start()
