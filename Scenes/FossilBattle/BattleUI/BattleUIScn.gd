extends BattleUIServer

const movesfx:AudioStream = preload("res://Assets/SFX/Battle/move.wav")
const selectsfx:AudioStream = preload("res://Assets/SFX/Battle/select.wav")

onready var sound0:AudioStreamPlayer = $AudioStreamPlayer
onready var sound1:AudioStreamPlayer = $AudioStreamPlayer2

onready var button_info:UIItem = $Actions/Info
onready var button_skill:UIItem = $Actions/Skill
onready var button_end:UIItem = $Actions/End
onready var button_swap:UIItem = $Actions/Swap

var actions_ui_items:Array = []

func _ready():
	actions_ui_items = [button_skill, button_end, button_info, button_swap]
	cursor = $UICursor

func fetch_bvs_into_items():
	for bv in battle_team.get_all_zones() + enemy_team.get_all_zones():
		if bv != null:
			add_item(bv)

func fetch_own_bvs_into_items():
	for bv in battle_team.get_all_zones():
		if bv != null:
			add_item(bv)

func go():
	show()
	status = STATUS.ACTIONS
	set_status(STATUS.ACTIONS, true)
	$InfoCenter/AnimationPlayer.play("Popup")
	focused = true
	

func end(action:BattleAction.Generic):
	focused = false
	selected_bv = null
	selected_skill = null
	
	close_status()
	cursor.vanish()
	emit_signal("action_request", action)
	
	$InfoCenter/AnimationPlayer.play_backwards("Popup")


enum STATUS {
	ACTIONS,
	SELECT_VIVO_SWAP,
	SELECT_VIVO_SKILL,
	SKILL,
	SELECT_VIVO_TARGET,
	VIEW_VIVO,
}
var status:int setget set_status

func close_status():
	clear()
	
	match status:
		STATUS.SELECT_VIVO_SWAP, \
		STATUS.SELECT_VIVO_SKILL, \
		STATUS.SELECT_VIVO_TARGET, \
		STATUS.VIEW_VIVO:
			$VivoInfo/AnimationPlayer.stop()
			$VivoInfo/AnimationPlayer.play_backwards("Show")
	
	match status:
		STATUS.ACTIONS:
			$Actions.actuate(true)
			yield($Actions/Tween, "tween_completed")
		STATUS.SELECT_VIVO_SWAP:
			battle_team.animations.play("RESET")
		STATUS.SKILL:
			$SkillSelect.retreat_skills()
		STATUS.SELECT_VIVO_TARGET:
			cursor.texture = preload("res://Assets/Battle/indicators/map_select_bv.png")

var selected_bv:BattleVivo
var selected_skill:Skill
var selected_action_button:UIItem

func set_status(new:int, force:bool = false):
	if not force and new == status:
		return
	
	if new != status:
		close_status()
	
	status = new
	match status:
		STATUS.ACTIONS:
			make_from_array(actions_ui_items)
			$Actions.actuate()
			sound1.stream = preload("res://Assets/SFX/Battle/battle_ui_open.wav")
			sound1.play()
			$InfoCenter.recieve("Select an action.")
		STATUS.SELECT_VIVO_SWAP:
			fetch_own_bvs_into_items()
			for iter in items:
				iter.operative = battle_team.is_sz(iter)
			battle_team.animations.play("SwapOut")
			$InfoCenter.recieve("Swap to the Escape Zone?")
		STATUS.SELECT_VIVO_SKILL:
			fetch_own_bvs_into_items()
			var allowed:Array = battle_team.get_avaliable()
			for iter in items:
				iter.operative = iter in allowed
			$InfoCenter.recieve("Select an acting Vivosaur.")
		STATUS.SKILL:
			var new_items = yield($SkillSelect.push_skills(selected_bv.vivo.dbentry.skills, selected_bv, battle_team), "completed")
			make_from_array(new_items)
		STATUS.SELECT_VIVO_TARGET:
			fetch_bvs_into_items()
			var allowed:Array = BattleRules.allowed_targets(selected_skill, selected_bv, battle_team, enemy_team)
			for iter in items:
				iter.operative = iter in allowed
			match selected_skill.target:
				Skill.TARGET.ALL_ENEMY, \
				Skill.TARGET.ALL_TEAM:
					cursor.texture = preload("res://Assets/Battle/indicators/map_select_team.png")
			$InfoCenter.recieve("Select a target.")
		STATUS.VIEW_VIVO:
			fetch_bvs_into_items()
			for iter in items:
				iter.operative = true
			$InfoCenter.recieve("Overview mode.")
	
	match status:
		STATUS.SELECT_VIVO_SWAP, \
		STATUS.SELECT_VIVO_SKILL, \
		STATUS.SELECT_VIVO_TARGET, \
		STATUS.VIEW_VIVO:
			$VivoInfo/AnimationPlayer.stop()
			$VivoInfo/AnimationPlayer.play("Show")
	
	if selected_bv != null and status == STATUS.SELECT_VIVO_SKILL:
		move_to(selected_bv)
	elif selected_action_button != null and status == STATUS.ACTIONS:
		move_to(selected_action_button)
	else:
		to_first_operative()

func enter_current_item():
	current_item.enter()
	if not sound1.playing and not (sound0.stream == selectsfx and sound0.playing):
		sound0.stream = movesfx
		sound0.play()
	
	match status:
		STATUS.ACTIONS:
			match current_item:
				button_info:
					$InfoCenter.recieve("Freely view Vivosaur stats.")
				button_skill:
					$InfoCenter.recieve("Use a skill.")
				button_end:
					$InfoCenter.recieve("End the current turn.")
				button_swap:
					$InfoCenter.recieve("Retreat the Attack Zone.")
		STATUS.SELECT_VIVO_SWAP:
			battle_team.swap_arrow_curve.position.y = abs(battle_team.swap_arrow_curve.position.y) * Util.sign_bool(current_item == battle_team.sz1)
			battle_team.swap_arrow_curve.flip_v = current_item == battle_team.sz1
			battle_team.swap_arrow_curve.show()
		STATUS.SKILL:
			var sk:Skill = current_item.skill
			var buf:String
			if sk.power > 0:
				buf += "Power: " + str(sk.power) + "\n"
			if sk.effect != Skill.EFFECT.NONE:
				buf += str(sk.effect_chance * 100) + "% chance to "
				if sk.effect == Skill.EFFECT.STATUS:
					buf += Skill.str_status_info(sk.status_effect)
				else:
					buf += Skill.str_effect(sk.effect)
			$InfoCenter.recieve(buf, true)
	
	match status:
		STATUS.SELECT_VIVO_SWAP, \
		STATUS.SELECT_VIVO_SKILL, \
		STATUS.SELECT_VIVO_TARGET, \
		STATUS.VIEW_VIVO:
			var team:BattleTeam = BattleRules.get_bv_team(current_item as BattleVivo, battle_team, enemy_team)
			$VivoInfo.set_bv(current_item as BattleVivo, team.is_az(current_item as BattleVivo), team.az_mods)

func select_current_item():
	if current_item != null and status != STATUS.VIEW_VIVO:
		sound0.stream = selectsfx
		sound0.play()
		match status:
			STATUS.ACTIONS:
				selected_action_button = current_item
				match current_item:
					button_info:
						set_status(STATUS.VIEW_VIVO)
					button_skill:
						if battle_team.get_avaliable().size() > 0:
							set_status(STATUS.SELECT_VIVO_SKILL)
						else:
							$InfoCenter.recieve("No Vivosaurs can act!")
							error_sound()
					button_end:
						yield(SubWindow.push_yn_dialogue("End Turn?", FFMenu.PROFILES.BATTLE), "closed")
						if SubWindow.last_yn_dialogue_affirmative():
							end(null)
					button_swap:
						if battle_team.can_swap():
							set_status(STATUS.SELECT_VIVO_SWAP)
						else:
							$InfoCenter.recieve("Cannot swap out!")
							error_sound()
			STATUS.SELECT_VIVO_SWAP:
				yield(SubWindow.push_yn_dialogue("Swap Out?", FFMenu.PROFILES.BATTLE), "closed")
				if SubWindow.last_yn_dialogue_affirmative():
					var action := BattleAction.Swap.new() 
					action.sz2 = current_item == battle_team.sz2
					end(action)
			STATUS.SELECT_VIVO_SKILL:
				selected_bv = current_item
				set_status(STATUS.SKILL)
			STATUS.SKILL:
				selected_skill = current_item.skill
				if selected_bv.has_status_effect(Skill.STATUS_EFFECT.SCARE) and selected_bv.scare_restricted_skills.has(selected_skill):
					$InfoCenter.recieve("Status Effects prevent the usage of this skill.")
					error_sound()
				elif selected_skill.shown_type == Skill.SKILL_TYPE.TEAM and not BattleRules.can_use_team_skills(battle_team):
					$InfoCenter.recieve("Team currently cannot perform Team Skills.")
					error_sound()
				elif selected_skill.fp > battle_team.fp:
					$InfoCenter.recieve("Not enough FP!")
					error_sound()
				elif Util.filter_null(BattleRules.allowed_targets(selected_skill, selected_bv, battle_team, enemy_team)).size() == 0:
					$InfoCenter.recieve("No targets availiable!")
				else:
					set_status(STATUS.SELECT_VIVO_TARGET)
			STATUS.SELECT_VIVO_TARGET:
				var action := BattleAction.Move.new()
				action.acting = selected_bv
				action.skill = action.acting.vivo.dbentry.skills.find(selected_skill)
				action.recieving = [current_item]
				end(action)

func dir_input(vec:Vector2) -> bool:
	match status:
		STATUS.ACTIONS:
			var new:UIItem
			match vec:
				Vector2.UP:    new = button_info
				Vector2.RIGHT: new = button_skill
				Vector2.DOWN:  new = button_end
				Vector2.LEFT:  new = button_swap
			if new != null and new != current_item:
				return move_to(new)
			return false
		_:
			move_dir(vec)
	
	return false

func cancel():
	match status:
		STATUS.SKILL:
			set_status(STATUS.SELECT_VIVO_SKILL)
		STATUS.SELECT_VIVO_TARGET:
			set_status(STATUS.SKILL)
		_:
			set_status(STATUS.ACTIONS)

func alt_inputs(ev:InputEvent):
	if ev.is_action_pressed("ui_cancel"):
		cancel()

func error_sound():
	sound0.stream = preload("res://Assets/SFX/Battle/battle_action_reject.wav")
	sound0.play()
