extends Node

var vivodb:Array = []

var player:HumanPlayer
var enemy_player:AIPlayer

var team:Team
var configured_team:Team
var enemy_team:Team

func _init():
	for i in range(Vivodata.metadb.size()):
		vivodb.append(Vivosaur.new(i))
	
	player = HumanPlayer.new()
	enemy_player = AIPlayer.new()
	
	player.label = "You"
	player.fp_per_turn = 200
	player.icon = preload("res://Assets/CharacterIcons/hunter_tricera.png")
	
	enemy_player.label = "Samurai"
	enemy_player.fp_per_turn = 200
	enemy_player.icon = preload("res://Assets/CharacterIcons/samurai.png")
	
	configured_team = Team.new()
