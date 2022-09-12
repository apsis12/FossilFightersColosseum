extends Object

class_name BitmapFontGenConfig

var charmap:Texture
var resource_save_path:String

var height:int
var width:int
var seperate:int = 0

var unicode_order:PoolIntArray = \
	PoolIntArray([ ord(' ') ]) + \
	Util.ordrange('A', 'Z') + \
	Util.ordrange('a', 'z') + \
	Util.ordrange('0', '9')

var width_exceptions:Dictionary = {}
