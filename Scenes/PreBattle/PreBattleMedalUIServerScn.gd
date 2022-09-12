extends PreBattleMedalUIServer

func _ready():
	cursor = $UICursor
	menu_node = $Menu
	
	make_from_children($Slots/Own)
	make_from_children($Slots/Enemy)
	add_item($Ready)
	add_item($Back)
	$UICursorOscillate.play("cursor")
	
	if TeamFile.team_exists("Main"):
		GameVars.team = TeamFile.retrieve_team("Main")
	else:
		GameVars.team = Team.new()
		GameVars.team.generate_random()
	
	if TeamFile.team_exists("Enemy"):
		GameVars.enemy_team = TeamFile.retrieve_team("Enemy")
	else:
		GameVars.enemy_team = Team.new()
		GameVars.enemy_team.generate_random()
	
	set_own(GameVars.team)
	set_enemy(GameVars.enemy_team)
	
	to_first_operative()
	
	emit_signal("slots_updated")

func set_team(vivos:Array, node:Node2D):
	var i:int = 0
	for vivo in vivos:
		vivo = vivo as Vivosaur
		if vivo == null:
			(node.get_child(i) as MedalSlot).medal = null
		else:
			var medal:DinoMedal = DinoMedal.new(GameVars.vivodb[vivo.list_index])
			(node.get_child(i) as MedalSlot).medal = medal
			medal.global_position = (node.get_child(i) as MedalSlot).global_position
			$Medals.add_child(medal)
		i += 1

func set_own(team:Team):
	$TeamHolderBattle/TeamName.text = team.label
	set_team(team.get_all(), $Slots/Own)

func set_enemy(team:Team):
	set_team(team.get_battlers(), $Slots/Enemy)
