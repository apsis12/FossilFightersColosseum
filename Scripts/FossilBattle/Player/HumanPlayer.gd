extends BattlePlayer

class_name HumanPlayer

var ui:BattleUIServer

func process_turn(_enemy_team:BattleTeam, _attack_cnt:int) -> BattleAction.Generic:
	ui.go()
	var action = yield(ui, "action_request")
	return action
