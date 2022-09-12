extends Node2D

class_name BattleTeam

# Nodes #################
var battle_vivo_1:BattleVivo
var battle_vivo_2:BattleVivo
var battle_vivo_3:BattleVivo
##########################

func get_battle_vivos() -> Array:
	return [battle_vivo_1, battle_vivo_2, battle_vivo_3]

var team:Team setget set_team

func set_team(new:Team):
	team = new
	var vivos:Array = team.get_battlers()
	var battle_vivos:Array = get_battle_vivos()
	for i in range(battle_vivos.size()):
		(battle_vivos[i] as BattleVivo).vivo = vivos[i] as Vivosaur

##################

var fp:int = 0 setget set_fp
const max_fp:int = 999
func set_fp(inp:int):
	fp = int(clamp(inp, 0, max_fp))

var esc_turn_cnt:int = 0

var se_applied_bvs:Array = []
var az_mods:PoolIntArray = [0, 0, 0, 0]

var az:BattleVivo
var sz1:BattleVivo
var sz2:BattleVivo
var esc:BattleVivo

func get_az_mod_attack() -> int:
	return az_mods[0]
func get_az_mod_defense() -> int:
	return az_mods[1]
func get_az_mod_accuracy() -> int:
	return az_mods[2]
func get_az_mod_evasion() -> int:
	return az_mods[3]

func get_all_zones() -> Array:
	return Util.filter_null([az, sz1, sz2, esc])
func get_sz() -> Array:
	return Util.filter_null([sz1, sz2])

func is_esc(bv:BattleVivo) -> bool:
	return bv == esc
func is_sz(bv:BattleVivo) -> bool:
	return bv == sz1 or bv == sz2
func is_az(bv:BattleVivo) -> bool:
	return bv == az

func reset():
	for bv in get_all_zones():
		bv.exhausted_turn = false
		bv.has_linked = false

func __eval_all_support_effects(type:int) -> PoolIntArray:
	var ret:PoolIntArray = [0, 0, 0, 0]
	for iter in get_sz():
		if iter != null and iter.vivo.dbentry.support_type == type:
			ret = Util.add_pia(ret, iter.vivo.get_support_effects())
	return ret

func eval_all_support_effects_own():
	return __eval_all_support_effects(VivoDBEntry.SUPPORT_TYPE.OWN)
func eval_all_support_effects_enemy():
	return __eval_all_support_effects(VivoDBEntry.SUPPORT_TYPE.ENEMY)

func __eval_support_effect(type:int, which:int) -> int:
	var ret:int = 0
	for iter in get_sz():
		if iter != null and iter.vivo.dbentry.support_type == type:
			ret += iter.vivo.get_support_effects()[which]
	return ret

func eval_support_effect_own(which:int) -> int:
	return __eval_support_effect(VivoDBEntry.SUPPORT_TYPE.OWN, which)
func eval_support_effect_enemy(which:int) -> int:
	return __eval_support_effect(VivoDBEntry.SUPPORT_TYPE.ENEMY, which)

func get_non_esc() -> Array:
	var ret:Array = get_all_zones()
	ret.erase(esc)
	return ret

func get_avaliable() -> Array:
	var ret:Array = []
	for iter in get_non_esc():
		if not iter.exhausted_turn and not iter.has_status_effect(Skill.STATUS_EFFECT.SLEEP):
			ret.append(iter)
	return ret

func is_defeated() -> bool:
	return get_all_zones().size() == 0

func can_swap() -> bool:
	return esc == null and get_sz().size() > 0 and not az.has_status_effect(Skill.STATUS_EFFECT.EXCITE)


var faint_ring:Array = []

func faint(bv:BattleVivo):
	bv.fainted = true
	
	faint_ring.erase(bv)
	faint_ring.append(bv)
	
	if bv == az:
		az = null
	elif bv == sz1:
		sz1 = null
	elif bv == sz2:
		sz2 = null
	elif bv == esc:
		esc = null

enum {
	ZONE_AZ,
	ZONE_SZ1,
	ZONE_SZ2,
	ZONE_ESC,
}

func get_zone(zone_enum:int) -> BattleVivo:
	match zone_enum:
		ZONE_AZ: return az
		ZONE_SZ1: return sz1
		ZONE_SZ2: return sz2
		ZONE_ESC: return esc
	return null

func assign_zone(bv:BattleVivo, zone_enum:int):
	match zone_enum:
		ZONE_AZ: az = bv
		ZONE_SZ1: sz1 = bv
		ZONE_SZ2: sz2 = bv
		ZONE_ESC: esc = bv
		_: assert(false)

func reset_zoning():
	az = battle_vivo_1 if battle_vivo_1.vivo != null else null
	sz1 = battle_vivo_2 if battle_vivo_2.vivo != null else null
	sz2 = battle_vivo_3 if battle_vivo_3.vivo != null else null
	esc = null

func assume_az() -> bool:
	var sz_2:bool = sz1 == null
	
	if az == null:
		var new_az:BattleVivo = sz2 if sz_2 else sz1
		
		if new_az == null:
			az = esc
			esc = null
		else:
			az = new_az
			if sz_2:
				sz2 = null
			else: 
				sz1 = null
		
		return true
	
	return false

func swap_out(sz_2:bool = false) -> bool:
	if can_swap():
		var new_az:BattleVivo = sz2 if sz_2 else sz1
		if new_az != null:
			esc = az
			az = new_az
			if sz_2:
				sz2 = null
			else:
				sz1 = null
			
			return true
	return false

func force_swap_out() -> bool:
	if not swap_out():
		return swap_out(true)
	else:
		return true

func unescape() -> int:
	if esc != null:
		var new_zone:int = -1
		
		if sz1 == null:
			sz1 = esc
			new_zone = ZONE_SZ1
		elif sz2 == null:
			sz2 = esc
			new_zone = ZONE_SZ2
		else:
			return -1
		
		esc = null
		
		return new_zone
	return -1

func displace() -> Array:
	var ret:Array = []
	
	var active:Array = get_all_zones()
	az = null
	sz1 = null
	sz2 = null
	esc = null
	
	for bv in active:
		var new_zone:int
		while true:
			randomize()
			new_zone = randi() % 4
			var tmp:BattleVivo = get_zone(new_zone)
			if tmp == null:
				assign_zone(bv, new_zone)
				ret.append(new_zone)
				break
	
	return ret
