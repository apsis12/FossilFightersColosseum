extends SceneTree

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/FFBasicFont.tres"
#
#	config.charmap = preload("res://Assets/Font/CharMapBasic.png")
#	config.width = 6
#	config.height = 11
#
#	config.unicode_order = config.unicode_order + Util.ordarray(['!', '.', '?', '\'', ',', '/', '%', '-', '(', ')', '=', '+', '*', '#', '&', '~', '@', ':', ';', '"', '<', '>', '\\', '`'])
#
#	config.width_exceptions[ord('I')] = 2
#	config.width_exceptions[ord('i')] = 2
#	config.width_exceptions[ord('l')] = 3
#	config.width_exceptions[ord('r')] = 5
#	config.width_exceptions[ord('j')] = 5
#	config.width_exceptions[ord('t')] = 5
#	config.width_exceptions[ord('1')] = 3
#	config.width_exceptions[ord('4')] = 5
#
#	config.width_exceptions[ord('!')] = 2
#	config.width_exceptions[ord('.')] = 3
#	config.width_exceptions[ord(',')] = 3
#	config.width_exceptions[ord('(')] = 4
#	config.width_exceptions[ord(')')] = 4
#	config.width_exceptions[ord(':')] = 3
#	config.width_exceptions[ord(';')] = 3
#	config.width_exceptions[ord('\'')] = 3
#	config.width_exceptions[ord('`')] = 3
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/FFBasicFontShadow.tres"
#
#	config.charmap = preload("res://Assets/Font/CharMapBasicShadow.png")
#	config.width = 6
#	config.height = 12
#
#	config.unicode_order = config.unicode_order + Util.ordarray(['!', '.', '?', '\'', ',', '/', '%', '-', '(', ')', '=', '+', '*', '#', '&', '~', '@', ':', ';', '"', '<', '>', '\\', '`'])
#
#	config.width_exceptions[ord('I')] = 2
#	config.width_exceptions[ord('i')] = 2
#	config.width_exceptions[ord('l')] = 3
#	config.width_exceptions[ord('r')] = 5
#	config.width_exceptions[ord('j')] = 5
#	config.width_exceptions[ord('t')] = 5
#	config.width_exceptions[ord('1')] = 3
#	config.width_exceptions[ord('4')] = 5
#
#	config.width_exceptions[ord('!')] = 2
#	config.width_exceptions[ord('.')] = 3
#	config.width_exceptions[ord(',')] = 3
#	config.width_exceptions[ord('(')] = 4
#	config.width_exceptions[ord(')')] = 4
#	config.width_exceptions[ord(':')] = 3
#	config.width_exceptions[ord(';')] = 3
#	config.width_exceptions[ord('\'')] = 3
#	config.width_exceptions[ord('`')] = 3
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/FFStatNumbers.tres"
#
#	config.charmap = preload("res://Assets/Font/StatNumbersMap.png")
#	config.width = 8
#	config.height = 15
#
#	config.unicode_order = PoolIntArray([ ord(' ') ]) + Util.ordrange('0', '9') + Funco.ordarray(['%', '-'])
#
#	config.width_exceptions[ord('1')] = 6
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/FFStatNumbersNegative.tres"
#
#	config.charmap = preload("res://Assets/Font/SupportEffectsNegativeMap.png")
#	config.width = 8
#	config.height = 15
#
#	config.unicode_order = PoolIntArray([ ord(' ') ]) + Util.ordrange('0', '9') + Funco.ordarray(['%', '-'])
#
#	config.width_exceptions[ord('1')] = 6
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/FFMedalDigit.tres"
#
#	config.charmap = preload("res://Assets/Font/DinoMedalNumbers.png")
#	config.width = 4
#	config.height = 5
#
#	config.unicode_order = PoolIntArray([ ord(' ') ]) + Util.ordrange('0', '9')
#
#	config.width_exceptions[ord('1')] = 3
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/FFVivoIndexDigit.tres"
#
#	config.charmap = preload("res://Assets/Font/VivoIndexMap.png")
#	config.width = 9
#	config.height = 6
#
#	config.unicode_order = PoolIntArray([ ord(' ') ]) + Util.ordrange('0', '9')
#
#	config.width_exceptions[ord('1')] = 6
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/SupportEffectsNegativeBattleMap.tres"
#
#	config.charmap = preload("res://Assets/Font/SupportEffectsNegativeBattleMap.png")
#	config.width = 5
#	config.height = 8
#
#	config.unicode_order = PoolIntArray([ ord(' ') ]) + Util.ordrange('0', '9') + PoolIntArray([ ord('-') ])
#
#	config.width_exceptions[ord('1')] = 4
#	config.width_exceptions[ord('-')] = 7
#
#	BitmapFontGen.generate(config)
#	quit()

#func _init():
#	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
#	config.resource_save_path = "res://Fonts/Resource/SupportEffectsPositiveBattleMap.tres"
#
#	config.charmap = preload("res://Assets/Font/SupportEffectsPositiveBattleMap.png")
#	config.width = 5
#	config.height = 8
#
#	config.unicode_order = PoolIntArray([ ord(' ') ]) + Util.ordrange('0', '9') + PoolIntArray([ ord('+') ])
#
#	config.width_exceptions[ord('1')] = 4
#	config.width_exceptions[ord('+')] = 7
#
#	BitmapFontGen.generate(config)
#	quit()

func _init():
	var config:BitmapFontGenConfig = BitmapFontGenConfig.new()
	config.resource_save_path = "res://Fonts/Resource/BattleNumbersMap.tres"
	
	config.charmap = preload("res://Assets/Font/BattleNumbersMap.png")
	config.width = 16
	config.height = 30
	
	config.unicode_order = Util.ordrange('0', '9')
	
	config.width_exceptions[ord('1')] = 12
	
	BitmapFontGen.generate(config)
	quit()
