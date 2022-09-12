extends Node

var file:File
var team_dir_str:String
var team_dir:Directory

func _init():
	team_dir_str = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/FossilFightersTeams/"
	file = File.new()
	team_dir = Directory.new()
	assert(team_dir.make_dir_recursive(team_dir_str) == OK, "cannot create save file directory")
	team_dir.open(team_dir_str)


func team_exists(inp:String) -> bool:
	return file.file_exists(team_dir_str + inp)


func retrieve_team(inp:String) -> Team:
	assert(team_exists(inp))
	file.open(team_dir_str + inp, File.READ)
	var fileteam = file.get_var(true)
	assert(fileteam is PoolIntArray)
	return create_team(fileteam, inp)


func correct_name(title:String) -> String:
	return Util.tr_d(title.strip_edges().strip_escapes(), ["/", "\\", ">"])


func save_team(team:Team, title:String) -> bool:
	file.open(team_dir_str + title, File.WRITE)
	file.store_var(create_file_team(team))
	return true


static func create_team(fileteam:PoolIntArray, label:String):
	assert(fileteam.size() == 5)
	
	var arr:Array = []
	
	for ind in fileteam:
		if ind < 0:
			arr.append(null)
		else:
			arr.append(GameVars.vivodb[ind])
	
	var team:Team = Team.new()
	team.set_array(arr)
	team.label = label
	
	return team


static func create_file_team(team:Team) -> PoolIntArray:
	var arr:PoolIntArray = []
	
	for vivo in team.get_all():
		if vivo == null:
			arr.append(-1)
		else:
			arr.append(vivo.list_index)
	
	return arr


func delete_team(title:String):
	if team_exists(title):
		team_dir.remove(team_dir_str + title)


func __sort_saved_teams(a:String, b:String):
	return file.get_modified_time(a) < file.get_modified_time(b)


func list_saved_teams() -> PoolStringArray:
	var ret:Array = Util.list_files_in_directory(team_dir)
	ret.sort_custom(self, "__sort_saved_teams")
	return PoolStringArray(ret)
