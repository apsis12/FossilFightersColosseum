extends Node2D

var configured_team:Team

func _init():
	configured_team = Team.new()

func _on_UI_slots_updated():
	var arr:Array = []
	for slot in $UI/Slots/Own.get_children():
		if slot == null:
			arr.append(null)
		elif slot.medal != null and slot.medal.vivo != null:
			arr.append(slot.medal.vivo)
	configured_team.set_array(arr)
	$VivoView/Slides/TeamAnalysis.update_team_information(configured_team)

func _ready():
	Canvas.root_canvas_node = self
	
	$VivoView/CryButton.hide()
	$UI.make_from_children($VivoView/Tabs)
	$UI/TeamHolderBattle/Player.text = GameVars.player.label
	$UI/TeamHolderEnemy/Player.text = GameVars.enemy_player.label
	
	modulate = Color.black
	yield(Canvas.interpolate_screen_modulation(Color.white, 0.2), "tween_all_completed")

func _on_Ready_selected(_node) -> void:
	$UI.focused = false
	var vivos:Array = []
	for iter in $UI/Slots/Own.get_children():
		if (iter as MedalSlot).medal != null:
			vivos.append((iter as MedalSlot).medal.vivo)
		else:
			vivos.append(null)
	GameVars.configured_team.set_array(vivos)
	if GameVars.configured_team.is_valid():
		yield(Canvas.interpolate_screen_modulation(Color.black, 0.2), "tween_all_completed")
		get_tree().change_scene("res://Scenes/FossilBattle/FossilBattle.tscn")
	else:
		SubWindow.push_notification("Place a vivosaur in the AZ.")
		$UI.focused = true

func _on_Back_selected(_node) -> void:
	$UI.focused = false
	yield(Canvas.interpolate_screen_modulation(Color.black, 0.2), "tween_all_completed")
	get_tree().change_scene("res://Scenes/Main/Main.tscn")
