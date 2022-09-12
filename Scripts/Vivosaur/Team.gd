extends Object

class_name Team

var label:String

var AZ: Vivosaur
var SZ1: Vivosaur
var SZ2: Vivosaur

var R1: Vivosaur
var R2: Vivosaur

func set_array(arr:Array):
	var size = arr.size()
	for i in range(5):
		var vivo:Vivosaur = null
		if i < size and arr[i] is Vivosaur:
			vivo = arr[i]
		match i:
			0: AZ  = vivo
			1: SZ1 = vivo
			2: SZ2 = vivo
			3: R1  = vivo
			4: R2  = vivo

func generate_random(member_count:int = 5):
	member_count = int(clamp(member_count, 0, 5))
	var arr:Array = []
	for _i in range(member_count):
		var vivosaur:Vivosaur = Vivosaur.new()
		randomize()
		vivosaur.list_index = randi() % int(min(114, Vivodata.metadb.size()))
		arr.append(vivosaur)
	set_array(arr)
	label = "Randomly Generated"


func get_all() -> Array:
	return [AZ, SZ1, SZ2, R1, R2]

func get_battlers() -> Array:
	return [AZ, SZ1, SZ2]

func get_reserve() -> Array:
	return [R1, R2]

func is_valid() -> bool:
	return AZ != null

func is_empty() -> bool:
	for vivo in get_all():
		if vivo != null:
			return false
	return true

func get_total_lp() -> int:
	var ret:int = 0
	for i in get_battlers():
		if i != null:
			ret += (i as Vivosaur).lp
	return ret
