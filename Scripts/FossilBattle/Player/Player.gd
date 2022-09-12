extends Object

class_name BattlePlayer

var label:String = "Player"
var fp_per_turn:int = 280
var icon:StreamTexture

var battle_team:BattleTeam

func process_turn(_enemy_team:BattleTeam, _attack_cnt:int) -> BattleAction.Generic:
	return null
