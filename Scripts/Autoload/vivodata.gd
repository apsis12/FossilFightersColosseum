extends Node

var metadb:Array

var file:File

func file_get_var(path:String):
	file.open(path, File.READ)
	var result = file.get_var()
	file.close()
	return result

func get_json(jsonfile:String):
	file.open(jsonfile, File.READ)
	var output = parse_json(file.get_as_text())
	file.close()
	return output

func _init():
	file = File.new()
	
	var meta:Array = get_json("res://Vivodata/Json/vivodata.json")
	var skills:Dictionary = get_json("res://Vivodata/Json/vivoskill.json")
	
	for iter in meta:
		var entry:VivoDBEntry = VivoDBEntry.new()
		entry.import(iter, skills)
		metadb.append(entry)
