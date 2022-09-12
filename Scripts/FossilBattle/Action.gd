extends Object

class_name BattleAction

class Generic:
	# Represents end of turn
	pass

class Move extends Generic:
	var acting:BattleVivo
	var recieving:Array
	var skill:int

class Swap extends Generic:
	var sz2:bool = false
