extends FossilBattle

onready var tween:Tween = $Tween
onready var sfx:AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	Canvas.root_canvas_node = self
	
	player_1 = GameVars.player
	player_1.ui = $BattleUI
	player_1.ui.focused = false
	player_2 = GameVars.enemy_player
	
	player_1.battle_team = $TeamL
	player_1.ui.battle_team = $TeamL
	player_1.ui.enemy_team = $TeamR
	player_1.battle_team.fp_indicator = $FPIndicatorL
	
	$TeamR.flip = true
	player_2.battle_team = $TeamR
	player_2.battle_team.fp_indicator = $FPIndicatorR
	
	player_1.battle_team.team = GameVars.configured_team
	player_2.battle_team.team = GameVars.enemy_team
	
	player_1.battle_team.reset_zoning()
	player_2.battle_team.reset_zoning()
	
	$LPCompare.set_players(player_1, player_2)
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	battle_init()

func scn_faint(bv:BattleVivo):
	bv.animate("Faint")
	yield((bv.animations as AnimationPlayer), "animation_finished")
	bv.hide()


func message(msg:String):
	$BarNotification.show_text(msg)


func battle_init_hook():
	attacking.battle_team.enter_battle()
	defending.battle_team.enter_battle()

func battle_after_init_hook():
	$AnimationPlayer.play("Initialize")
	yield($AnimationPlayer, "animation_finished")

func battle_end_hook(winner:BattlePlayer):
	yield(Canvas.interpolate_screen_modulation(Color.black, 0.1), "tween_all_completed")
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func apply_se_hook(bv:BattleVivo, team:BattleTeam, remove:bool):
	team.az_mods_indicator.push_mods(team.az_mods)
	if not remove:
		bv.animate("Activate_SE")
		yield(team.az_mods_indicator.tween, "tween_all_completed")
		yield(get_tree().create_timer(0.5), "timeout")

func change_fp_hook(team:BattleTeam, fp:int):
	team.fp_indicator.push_change(team.fp, fp)
	yield(get_tree().create_timer(0.75), "timeout")

func beginning_of_turn_hook():
	sfx.stream = preload("res://Assets/SFX/Battle/turn_start.wav")
	sfx.play()
	
	attacking.battle_team.fp_indicator.animations.play("Attack")
	defending.battle_team.fp_indicator.animations.play("Retreat")
	
	attacking.battle_team.start_turn(true)
	defending.battle_team.start_turn(false)
	
	if attacking.battle_team.tween.is_active():
		yield(attacking.battle_team.tween, "tween_all_completed")

func end_of_turn_hook():
	for team in [attacking.battle_team, defending.battle_team]:
		for bv in team.get_all_zones():
			if bv.animations.current_animation == "Hit":
				yield(bv.animations, "animation_finished")

func start_move_hook(action:BattleAction.Move):
	$SkillIndicator.show_skill(action.acting.vivo.dbentry.skills[action.skill])
	
	for bv in get_all_avaliable_bvs():
		if bv == action.acting or action.recieving.has(bv):
			tween.interpolate_property(bv, "modulate", bv.modulate, Color.white, 0.1)
		else:
			tween.interpolate_property(bv, "modulate", bv.modulate, Color("777777"), 0.1)
	tween.start()
	yield(tween, "tween_all_completed")

func end_move_hook(action:BattleAction.Move):
	$SkillIndicator.retreat()
	
	for bv in get_all_non_esc_bvs():
		if bv.exhausted_turn:
			bv.stop_animate()
			tween.interpolate_property(bv, "modulate", bv.modulate, Color("444444"), 0.1)
		else:
			tween.interpolate_property(bv, "modulate", bv.modulate, Color.white, 0.1)
	tween.start()
	for bv in attacking.battle_team.get_non_esc():
		if not bv.animations.is_playing():
			bv.animate("Engage")

func end_of_actions_hook():
	for bv in get_all_non_esc_bvs():
		tween.interpolate_property(bv, "modulate", bv.modulate, Color.white, 0.1)
	tween.start()
	yield(tween, "tween_all_completed")

func alter_health_hook(bv:BattleVivo, _team:BattleTeam, dlp:int, faint:bool):
	if dlp <= 0:
		bv.animate_hit(false)
	else:
		bv.animate_heal()
	bv.lp_bar.animate_lp_change(dlp, bv.vivo.lp)
	yield(bv.lp_bar.tween, "tween_all_completed")
	if faint:
		yield(scn_faint(bv), "completed")

func hit_hook(action:BattleAction.Move, target:BattleVivo, skill:Skill, damage:int, crit:bool, faint:bool):
	for bv in defending.battle_team.get_all_zones():
		bv.indicate_type_advantage(action.acting)
	
	var hit_cnt:int = skill.hit_cnt
	var dmg_sofar:int = 0
	var offsetted:int = int(1.5 * float(hit_cnt))
	
	for hit in range(hit_cnt):
		var hit_dmg:int
		if hit + 1 == hit_cnt:
			hit_dmg = damage - dmg_sofar
		else:
# warning-ignore:integer_division
			hit_dmg = damage / (offsetted - hit)
		dmg_sofar += hit_dmg
		
		action.acting.animate("Attack")
		yield(action.acting.attack_anim, "finished")
		
		if hit + 1 == hit_cnt and crit:
			target.animate_critical()
		else:
			target.animate_hit()
		target.lp_bar.animate_lp_change(-hit_dmg, target.vivo.lp)
		
		yield((target.animations as AnimationPlayer), "animation_finished")
	
	if faint:
		yield(scn_faint(target), "completed")
	
	var need_to_yield:bool = false
	var yield_on:BattleVivo
	for bv in defending.battle_team.get_all_zones():
		if bv.stop_indicate_type_advantage():
			need_to_yield = true
			yield_on = bv
	if need_to_yield:
		yield(yield_on.animations2, "animation_finished")

func miss_hook(_action:BattleAction.Move, _target:BattleVivo, _skill:Skill):
	yield(get_tree().create_timer(2), "timeout")

func move_zone_hook(team:BattleTeam, zones:Array):
	team.animate_move_zones(zones)
	yield(team.tween, "tween_all_completed")

func add_status_effect_hook(bv:BattleVivo):
	yield(bv.show_status_effect(), "completed")
	yield(get_tree().create_timer(0.75), "timeout")

func remove_status_effect_hook(bv:BattleVivo, effects:Array):
	yield(bv.hide_status_effect(effects), "completed")
	yield(get_tree().create_timer(0.75), "timeout")

func activate_ability_hook(bvs:Array, isolated:bool):
	var yield_on:GDScriptFunctionState
	for bv in bvs:
		yield_on = bv.animate_ability()
	sfx.stream = preload("res://Assets/SFX/Battle/enact_ability.wav")
	sfx.play()
	if isolated:
		yield(yield_on, "completed")
