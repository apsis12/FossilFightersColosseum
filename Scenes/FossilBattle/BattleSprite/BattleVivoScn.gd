extends BattleVivo

onready var tween:Tween = $Tween
onready var lp_bar:LPBar = $LPBar
onready var flip_node:Node2D = $Flip
onready var vivo_sprite:Sprite = $Flip/Sprite
onready var animations:AnimationPlayer = $AnimationPlayer
onready var animations2:AnimationPlayer = $AnimationPlayerNonMain
onready var attack_anim:Node2D = $Attack
onready var audio:AudioStreamPlayer = $AudioStreamPlayer

func set_vivo(new:Vivosaur):
	vivo = new
	if vivo == null:
		hide()
	else:
		health = vivo.lp
		vivo_sprite.texture = load(vivo.get_asset_path() + "BattleSprites/" + vivo.dbentry.label + ".png")
		lp_bar.assign_type(vivo.dbentry.element)
		$Attack.set_element(vivo.dbentry.element)
		show()

export var flip:bool = false setget set_flip
func set_flip(new:bool):
	flip = new
	flip_node.scale = Vector2(Util.sign_bool(flip), 1) 

func animate(animation:String):
	if animation == "Attack":
		$Attack.animate()
	elif animations.has_animation(animation):
		animations.play(animation)

func animate_hit(anim:bool = true):
	if anim:
		animate("Hit")
	audio.stream = preload("res://Assets/SFX/Battle/hit_map.wav")
	audio.play()

func animate_critical():
	animate("Critical")
	audio.stream = preload("res://Assets/SFX/Battle/critical_hit.wav")
	audio.play()

func animate_heal():
	audio.stream = preload("res://Assets/SFX/Battle/add_lp.wav")
	audio.play()

func stop_animate():
	animate("None")
	tween.interpolate_property(vivo_sprite, "position", vivo_sprite.position, Vector2.ZERO, 0.1)
	tween.start()

func indicate_type_advantage(against:BattleVivo):
	match BattleRules.element_match_bv(against, self):
		BattleRules.ELEMENT_MATCHUP.FAVORABLE:
			$Flip/TypeAdvantageArrow.flip_h = false
		BattleRules.ELEMENT_MATCHUP.UNFAVORABLE:
			$Flip/TypeAdvantageArrow.flip_h = true
		_: return
	
	animations2.play("TypeAdvantageOpen")

func _on_AnimationPlayerNonMain_animation_finished(anim_name: String):
	if anim_name == "TypeAdvantageOpen":
		animations2.play("TypeAdvantage")

func stop_indicate_type_advantage() -> bool:
	if animations2.is_playing() and animations2.current_animation == "TypeAdvantageOpen" or animations2.current_animation == "TypeAdvantage":
		animations2.play("TypeAdvantageClose")
		return true
	else:
		return false

var visible_status_effect:int = 0

func show_status_effect():
	$Timer.stop()
	visible_status_effect = status_effects.size() - 2
	_on_Timer_timeout()
	animations2.play("Add_SE")
	yield(animations2, "animation_finished")
	$Timer.start()

func hide_status_effect(effects:Array):
	$Timer.stop()
	visible_status_effect = 0
	
	for se in effects:
		$StatusEffect.texture = Skill.get_status_effect_icon(se.effect, se.severity)
		if se == effects.back() and status_effects.size() == 0:
			animations2.play("Remove_SE")
			yield(animations2, "animation_finished")
		else:
			$StatusEffect/Label.text = "1"
			yield(get_tree().create_timer(0.2), "timeout")
			$StatusEffect/Label.text = "0"
			audio.stream = preload("res://Assets/SFX/Battle/remove_status_effect.wav")
			audio.play()
			yield(get_tree().create_timer(1), "timeout")
	
	if status_effects.size() != 0:
		_on_Timer_timeout()
		$Timer.start()

func _on_Timer_timeout() -> void:
	if status_effects.size() > 0:
		visible_status_effect = wrapi(visible_status_effect + 1, 0, status_effects.size())
		
		$StatusEffect/Label.text = str(Skill.get_status_turn_endurance(status_effects[visible_status_effect].effect) - status_effects[visible_status_effect].turn_cnt)
		$StatusEffect.texture = Skill.get_status_effect_icon(status_effects[visible_status_effect].effect, status_effects[visible_status_effect].severity)
	else:
		$Timer.stop()

func animate_ability():
	animations2.play("Activate_Ability")
	yield(get_tree().create_timer(1), "timeout")
	$AnimatedSprite.play("None")
	animations2.stop()
