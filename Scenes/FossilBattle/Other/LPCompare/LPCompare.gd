extends Sprite

func set_players(p1:BattlePlayer, p2:BattlePlayer):
	$P1Icon.texture = p1.icon
	$P2Icon.texture = p2.icon
	$P1FP.text = str(p1.battle_team.team.get_total_lp())
	$P2FP.text = str(p2.battle_team.team.get_total_lp())
	$P1Name.text= p1.label
	$P2Name.text= p2.label
