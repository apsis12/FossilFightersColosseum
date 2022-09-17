extends PreBattleMedalUIServer

func _ready():
	cursor = $UICursor
	menu_node = $Menu
	
	make_from_children($Slots/Own)
	make_from_children($Slots/Enemy)
	add_item($Ready)
	add_item($Back)
	add_item($Load)
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

func set_team(vivos:Array, node:Node2D):
	var i:int = 0
	for vivo in vivos:
		vivo = vivo as Vivosaur
		if vivo == null:
			if (node.get_child(i) as MedalSlot).medal != null:
				(node.get_child(i) as MedalSlot).medal.queue_free()
			(node.get_child(i) as MedalSlot).medal = null
		else:
			var medal:DinoMedal
			if (node.get_child(i) as MedalSlot).medal == null:
				medal = DinoMedal.new(vivo)
				(node.get_child(i) as MedalSlot).medal = medal
				$Medals.add_child(medal)
			else:
				medal = (node.get_child(i) as MedalSlot).medal
				medal.vivo = vivo
			medal.global_position = (node.get_child(i) as MedalSlot).global_position
		i += 1

func set_own(team:Team):
	$TeamHolderBattle/TeamName.text = team.label
	set_team(team.get_all(), $Slots/Own)
	emit_signal("slots_updated")

func set_enemy(team:Team):
	set_team(team.get_battlers(), $Slots/Enemy)

func _on_ItemList_item_activated(index: int) -> void:
	$ItemList.focus_mode = Control.FOCUS_NONE
	$ItemList.hide()
	yield(SubWindow.push_dialogue({
		"Load Team into...": false,
		">cKEYOwn": true,
		">cKEYEnemy": true,
		"Back": true,
	}), "option_selected")
	if SubWindow.dialogue_get_last_key() == ">cKEYOwn":
		set_own(TeamFile.retrieve_team($ItemList.get_item_text(index)))
	elif SubWindow.dialogue_get_last_key() == ">cKEYEnemy":
		set_enemy(TeamFile.retrieve_team($ItemList.get_item_text(index)))
	focused = true

func _on_FfLoad_selected(_node) -> void:
	focused = false
	$ItemList.focus_mode = Control.FOCUS_ALL
	$ItemList.grab_focus()
	$ItemList.show()

func _unhandled_input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		focused = true
		$ItemList.focus_mode = Control.FOCUS_NONE
		$ItemList.hide()
