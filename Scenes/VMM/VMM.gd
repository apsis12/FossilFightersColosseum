extends Node2D

var team:Team

func _init():
	team = Team.new()

func _ready():
	Canvas.root_canvas_node = self
	$UI.make_from_children($VivoView/Tabs)
	$UI.add_item($VivoView/CryButton)
	
	modulate = Color.black
	yield(Canvas.interpolate_screen_modulation(Color.white, 0.5), "tween_all_completed")
	yield(SubWindow.push_notification("Welcome to the >cKEYVMM>cDEF. Start by assigning >cKEYDino Medals >cDEFto team slots.", 200), "closed")
	
	$UI.focused = true

func _on_UI_slots_updated():
	var arr:Array = []
	for slot in $UI.figure_team_slots():
		var house:MedalHouse = slot.house
		if house == null:
			arr.append(null)
		elif house.medal != null and house.medal.vivo != null:
			arr.append(house.medal.vivo)
	team.set_array(arr)
	$VivoView/Slides/TeamAnalysis.update_team_information(team)

func save_team():
	$UI.focused = false
	
	if team.is_empty():
		SubWindow.push_notification("At least one slot must be assigned.")
		$UI.focused = true
		return
	
	if not team.is_valid():
		yield(SubWindow.push_yn_dialogue("The >cKEYAZ >cDEFslot is not assigned, meaning this team cannot be used in battle. Save anyway?"), "closed")
		if not SubWindow.last_yn_dialogue_affirmative():
			$UI.focused = true
			return
	
	if $UI/TeamName/LineEdit.text.length() == 0:
		SubWindow.push_notification("Title length must be greater than zero.")
		$UI.focused = true
		return
	
	var title:String = TeamFile.correct_name($UI/TeamName/LineEdit.text)
	
	if title != $UI/TeamName/LineEdit.text:
		if title.length() == 0:
			SubWindow.push_notification("Invalid title that cannot be automatically corrected.")
			$UI.focused = true
			return
		
		yield(SubWindow.push_notification("Invalid title. Correcting to >cKEY" + title), "closed")
		$UI/TeamName/LineEdit.text = title
	
	if TeamFile.team_exists(title):
		yield(SubWindow.push_yn_dialogue(">cKEY" + title + " >cDEFalready exists. Would you like to overwrite it?"), "closed")
		if not SubWindow.last_yn_dialogue_affirmative():
			$UI.focused = true
			return
	
	TeamFile.save_team(team, title)
	
	yield(SubWindow.push_notification("Saved as >cKEY" + title), "closed")
	
	$UI.focused = true

func _on_Save_selected(_node):
	save_team()

func _on_Ok_selected(_node):
	yield(SubWindow.push_yn_dialogue("Exit the >cKEYVMM>cDEF? Any unsaved changes will be lost."), "closed")
	if SubWindow.dialogue_get_last_key() != "yes":
		return
	$UI.focused = false
	yield(Canvas.interpolate_screen_modulation(Color.black, 0.5), "tween_all_completed")
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _unhandled_input(event):
	if $UI.status == $UI.status_type.NORMAL:
		if event.is_action_pressed("save"):
			save_team()
		elif event.is_action_pressed("open_file"):
			$UI.user_query_load_team()
