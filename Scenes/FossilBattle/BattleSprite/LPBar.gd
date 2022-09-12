extends Sprite

class_name LPBar

onready var tween:Tween = $Tween
onready var tween2:Tween = $Tween2
onready var lp_indicator:Label = $Offset/LPIndicator

onready var normal_line:LPFill = $Fill/Normal
onready var damage_line:LPFill = $Fill/Damage
onready var healing_line:LPFill = $Fill/Healing

func assign_type(type:int):
	texture = load("res://Assets/Battle/Vivosaur/lp_bar/" + VivoDBEntry.str_element(type) + ".png")

var target_length:float = 0.0 setget set_target_length

func set_target_length(input:float):
	target_length = clamp(input, 0.0, LPFill.MAX_LENGTH)

const PRIMARY_TIME:float = 0.1
const OFFSET_TIME:float = 0.25
const AUXILIARY_TIME:float = 1.0

func animate_lp_change(dlp:int, max_lp:int):
	var distance:float = LPFill.MAX_LENGTH * float(dlp)/float(max_lp)
	
	text_indicate_lp_change(dlp)
	
	if distance != 0.0:
		set_target_length(target_length + distance)
		tween.remove_all()
		if distance < 0:
			healing_line.length = target_length
			tween.interpolate_property(normal_line, "length", normal_line.length, target_length, PRIMARY_TIME)
			tween.interpolate_property(damage_line, "length", normal_line.length, target_length, AUXILIARY_TIME, 0, 0, OFFSET_TIME)
		elif distance > 0:
			tween.interpolate_property(healing_line, "length", normal_line.length, target_length, PRIMARY_TIME)
			tween.interpolate_property(normal_line, "length", normal_line.length, target_length, AUXILIARY_TIME, 0, 0, OFFSET_TIME)
			tween.interpolate_property(damage_line, "length", normal_line.length, target_length, AUXILIARY_TIME, 0, 0, OFFSET_TIME)
		tween.start()

func text_indicate_lp_change(dlp:int):
	tween2.stop_all()
	lp_indicator.theme = preload("res://Fonts/Resource/FFStatNumbersPositive.tres") if dlp > 0 else preload("res://Fonts/Resource/FFStatNumbersNegative.tres")
	lp_indicator.text = str(abs(dlp))
	lp_ind_anim_part = STATE_NONE
	_next_lp_indicator_anim_part()


enum {
	STATE_NONE,
	STATE_UP,
	STATE_DOWN,
}

var lp_ind_anim_part = STATE_NONE

func _next_lp_indicator_anim_part():
	match lp_ind_anim_part:
		STATE_NONE:
			lp_indicator.show()
			tween2.interpolate_property(lp_indicator, "rect_position", Vector2.ZERO, Vector2(0, -20), 0.2, Tween.TRANS_QUART)
			tween2.start()
			lp_ind_anim_part = STATE_UP
		STATE_UP:
			tween2.interpolate_property(lp_indicator, "rect_position", Vector2(0, -20), Vector2.ZERO, 0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
			tween2.start()
			lp_ind_anim_part = STATE_DOWN
		STATE_DOWN:
			lp_indicator.hide()
			lp_ind_anim_part = STATE_NONE
