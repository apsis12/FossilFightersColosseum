extends Object

class_name Util

static func hook(obj:Object, method:String, args:Array = []):
	if obj.has_method(method):
		var tmp = obj.callv(method, args)
		if tmp is GDScriptFunctionState: yield(tmp, "completed")

static func array_is_uniform(arr:Array):
	if arr.size() != 0:
		var last_val = arr[0]
		for iter in arr:
			if iter != last_val:
				return false
			last_val = iter
	return true

static func array_random(arr:Array):
	if arr.size() > 0:
		randomize()
		return arr[randi() % arr.size()]
	return null

static func filter_null(inp:Array):
	var ret:Array = []
	for iter in inp:
		if iter != null:
			ret.append(iter)
	return ret

static func ordrange(char1:String, char2:String) -> PoolIntArray:
	return PoolIntArray(range(ord(char1), ord(char2) + 1))

static func ordarray(input:PoolStringArray) -> PoolIntArray:
	var ret:PoolIntArray = []
	for iter in input:
		ret.append(ord(iter))
	return ret

static func sign_bool(val:bool) -> int:
	# returns 1 if true, -1 if false
	return int(not val) - int(val)

static func rect_get_segments(rect:Rect2) -> Array:
	var points:PoolVector2Array = [ rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, rect.position + Vector2(0, rect.size.y) ]
	return [ Rect2(points[0], points[1]), Rect2(points[1], points[2]), Rect2(points[2], points[3]), Rect2(points[3], points[0]) ]

static func list_files_in_directory(dir:Directory) -> PoolStringArray:
	var files:PoolStringArray = []
	
	dir.list_dir_begin()
	while true:
		var file:String = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	
	return files

static func merge_dict(dict: Dictionary, dict_merge: Dictionary):
	var new:Dictionary = dict.duplicate()
	
	for key in dict_merge:
		new[key] = dict_merge[key]
	
	return new

static func tr_d(input:String, set:PoolStringArray) -> String:
	var ret := input
	for iter in set:
		ret = ret.replace(iter, "")
	return ret

static func add_pia(a:PoolIntArray, b:PoolIntArray) -> PoolIntArray:
	assert(a.size() == b.size())
	var ret := a
	for i in range(a.size()):
		ret[i] += b[i]
	return ret

static func sub_pia(a:PoolIntArray, b:PoolIntArray) -> PoolIntArray:
	assert(a.size() == b.size())
	var ret := a
	for i in range(a.size()):
		ret[i] -= b[i]
	return ret
