extends VMMUIServer

var dimensions:Vector3 = Vector3(5,5,13)
const house_dimensions:Vector2 = Vector2(45,32)

func _ready():
	cursor = $UICursor
	menu_node = $Menu
	generate_houses($Houses, $Medals)
	make_from_children($Slots)
	for iter in $Houses.get_children():
		make_from_children(iter)
	make_from_children($ShiftButtons)
	make_from_children($Sort)
	make_from_children($BottomRow)
	add_item($TeamName)
	back_button = $BottomRow/Back
	$Sort/Index.modulate = Color.slategray
	current_sort = $Sort/Index
	to_first_operative()
	shift(0)
	$UICursorOscillate.play("cursor")

var initial_group:int = 0

func generate_houses(housenode:Node2D, medalnode:Node2D):
	for z in range(dimensions.z):
		var group:Node2D = Node2D.new()
		housenode.add_child(group)
		var vivo_index_offset:int = int(z * dimensions.x * dimensions.y)
		for y in dimensions.y:
			for x in dimensions.x:
				var i:int = vivo_index_offset + y * dimensions.x + x
				var medal:DinoMedal = null
				if i < Vivodata.metadb.size(): 
					medal = DinoMedal.new(GameVars.vivodb[i])
					medalnode.add_child(medal)
				var house = MedalHouse.new(medal)
				house.medal = medal
				house.position = Vector2(x, y) * house_dimensions
				group.add_child(house)
				house.restore_medal()
		if z != 0:
			group.hide()
			for i in group.get_children():
				i.operative = false
				if i.medal != null:
					i.medal.hide()

func shift_button(node:UIItem):
	if input_conditions():
		($ShiftButtons/Sound as AudioStreamPlayer).play()
		match node.get_index():
			0: shift(-1)
			1: shift( 1)

const MEDALHOUSE_GRID_SHIFT_OFFSET:float = 500.0

func shift(shifts:int):
	if status == status_type.NORMAL:
		var group_count:int = $Houses.get_child_count()
		var former_position:Vector2 = current_item.get_global_rect_center()
		var cur_pos:int = 0
		
		for iter in $Houses.get_children():
			if iter.visible:
				cur_pos = iter.get_index()
				break
		
		var new_pos:int = wrapi(cur_pos + shifts, 0, group_count)
		
		for iter in $Houses.get_children():
			var ind:int = iter.get_index()
			
			(iter as Node2D).position.x = sign(ind - new_pos) * MEDALHOUSE_GRID_SHIFT_OFFSET
			
			if ind == new_pos:
				(iter as CanvasItem).show()
				
				for c in iter.get_children():
					if c is MedalHouse:
						if c.medal != null:
							c.medal.show()
						c.operative = true
						c.restore_medal()
			else:
				(iter as CanvasItem).hide()
				
				for c in iter.get_children():
					if c is MedalHouse:
						if not c.assigned and c.medal != null:
							c.medal.hide()
						c.operative = false
						c.restore_medal()
		
		($Page as Label).text = "Page " + str(new_pos + 1) + " of " + str(group_count)
		
		if not current_item.operative:
			to_area(former_position)

const SORT_FUNS:PoolStringArray = PoolStringArray([
	"sort_index", "sort_name", "sort_lp", "sort_element",
	"sort_type", "sort_size", "sort_support_type", "sort_total_fp",
	"sort_attack", "sort_defense", "sort_accuracy", "sort_evasion"
])

var current_sort:UIItem

func _on_SortButton_selected(node:UIItem):
	if node != current_sort:
		if current_sort != null:
			current_sort.modulate = Color.white
		node.modulate = Color.slategray
		audio1.stream = preload("res://Assets/SFX/UI/select.wav")
		audio1.play()
		
		var ind:int = node.get_index()
		
		if ind in range(SORT_FUNS.size()):
			sort_houses(SORT_FUNS[ind])
			current_sort = node


func _on_Clear_selected(_node):
	clear_slots()

func _on_Redo_selected(_node):
	undo_action(true)

func _on_Undo_selected(_node):
	undo_action()


func gen_load_tree(team_list:PoolStringArray):
	
	var load_tree:Dictionary = {
		"Load Team": false
	}
	for team in team_list:
		load_tree[team] = true
	
	var deletedict:Dictionary = {
		"Delete Team": false
	}
	for team in team_list:
		deletedict[team] = {
			"Permanently delete >cKEY" + team + " >cDEF?": false,
			"yes": 1,
			"no": 1,
		}
	deletedict[">cKEYBack"] = 1
	
	load_tree[">cKEYDelete Team"] = deletedict
	load_tree[">cKEYBack"] = true
	
	return load_tree

func get_saved_teams_crop() -> PoolStringArray:
	var list:PoolStringArray = TeamFile.list_saved_teams()
	
	if list.size() > 9:
		list.resize(9)
	
	return list

var dialogue:FFDialogue

func user_query_load_team():
	var list:PoolStringArray = get_saved_teams_crop()
	
	if list.empty():
		SubWindow.push_notification("No saved teams!")
		return
	
	dialogue = SubWindow.push_dialogue(gen_load_tree(list), self, "_load_dialogue_handler", FFMenu.PROFILES.FF1, Vector2(0, -90))
	yield(dialogue, "closed")
	
	if SubWindow.dialogue_last_path.size() == 0:
		return
	if SubWindow.dialogue_get_last_key() == ">cKEYBack":
		return
	
	load_team(TeamFile.retrieve_team(SubWindow.dialogue_get_last_key()))
	
	$TeamName/LineEdit.text = SubWindow.dialogue_get_last_key()

func _load_dialogue_handler(path:PoolStringArray, _val):
	if path.size() == 3:
		if path[0] == ">cKEYDelete Team" and path[2] == "yes":
			TeamFile.delete_team(path[1])
			
			var list:PoolStringArray = get_saved_teams_crop()
			
			if list.empty():
				dialogue.exit = true
				yield(dialogue, "closed")
				SubWindow.push_notification("No teams left.")
			else:
				dialogue.option_tree = gen_load_tree(list)

func _on_Load_selected(_node):
	user_query_load_team()
