extends BattleTeam

func _ready():
	battle_vivo_1 = $Sprites/AZ
	battle_vivo_2 = $Sprites/SZ1
	battle_vivo_3 = $Sprites/SZ2

onready var tween := $Tween
onready var animations := $AnimationPlayer
onready var battlers_node := $Sprites
onready var az_mods_indicator := $Sprites/AZ_Mods 
onready var swap_arrow_curve := $Sprites/SwapIndicators/SwapArrowCurve
onready var swap_arrow_straight := $Sprites/SwapIndicators/SwapArrowStraight
var fp_indicator:FPIndicator

var flip:bool = false setget set_flip
func set_flip(new:bool):
	flip = new
	for bv in get_battle_vivos():
		if bv != null:
			bv.flip = flip
			bv.position.x = abs(bv.position.x) * Util.sign_bool(flip)
	if az_mods != null:
		az_mods_indicator.position.x = abs(az_mods_indicator.position.x) * Util.sign_bool(flip)
	swap_arrow_curve.position.x = abs(swap_arrow_curve.position.x) * Util.sign_bool(flip)
	swap_arrow_straight.position.x = abs(swap_arrow_straight.position.x) * Util.sign_bool(not flip)
	swap_arrow_curve.flip_h = flip
	swap_arrow_straight.flip_h = flip

func reset_zoning():
	az = battle_vivo_1 if battle_vivo_1.vivo != null else null
	if az != null:
		az.position = AZ_POS * Vector2(Util.sign_bool(flip), 1)
	sz1 = battle_vivo_2 if battle_vivo_2.vivo != null else null
	if sz1 != null:
		sz1.position = SZ1_POS * Vector2(Util.sign_bool(flip), 1)
	sz2 = battle_vivo_3 if battle_vivo_3.vivo != null else null
	if sz2 != null:
		sz2.position = SZ2_POS * Vector2(Util.sign_bool(flip), 1)
	esc = null


const PREBATTLE_SPRITE_OFFSET:Vector2 = Vector2(300,300)
const ENGAGE_OFFSET:Vector2 = Vector2(20, -14)
const DISENGAGE_OFFSET:Vector2 = Vector2(-20, 14)
const ENGAGE_TIME:float = 0.5
const REPOSITION_TIME:float = 0.5
const ESC_ZONE_MODULATE:Color = Color("555555")

func enter_battle():
	for iter in get_all_zones():
		iter.lp_bar.animate_lp_change(iter.vivo.lp, iter.vivo.lp)

func start_turn(attacking:bool):
	set_engage(attacking)

func set_engage(val:bool):
	if battlers_node != null:
		var new_pos:Vector2 = ENGAGE_OFFSET if val else DISENGAGE_OFFSET
		tween.interpolate_property(battlers_node, "position", battlers_node.position, new_pos * Vector2(Util.sign_bool(flip), 1), ENGAGE_TIME)
		tween.start()
		
		for iter in get_avaliable():
			if val:
				iter.animate("Engage")
			else:
				iter.stop_animate()

func reset_position():
	tween.interpolate_property(battlers_node, "position", battlers_node.position, Vector2.ZERO, ENGAGE_TIME / 2)
	tween.start()
	for iter in get_avaliable():
		iter.stop_animate()

func __animate_reposition(bv:BattleVivo, pos:Vector2, col:Color = Color.white):
	tween.interpolate_property(bv, "position", bv.position, pos * Vector2(Util.sign_bool(flip), 1), REPOSITION_TIME, Tween.TRANS_EXPO)
	tween.interpolate_property(bv, "modulate", bv.modulate, col, REPOSITION_TIME)

const AZ_POS:Vector2 = Vector2.ZERO
const SZ1_POS:Vector2 = Vector2(-50, -60)
const SZ2_POS:Vector2 = Vector2(-50, 60)
const ESC_POS:Vector2 = Vector2(-100, 0)

func animate_move_zones(zones:Array):
	for zone in zones:
		match zone:
			ZONE_AZ:
				__animate_reposition(az, AZ_POS)
			ZONE_SZ1:
				__animate_reposition(sz1, SZ1_POS)
			ZONE_SZ2:
				__animate_reposition(sz2, SZ2_POS)
			ZONE_ESC:
				__animate_reposition(esc, ESC_POS, ESC_ZONE_MODULATE)
				esc.animate("None")
			_:
				return
	tween.start()
	yield(tween, "tween_all_completed")
