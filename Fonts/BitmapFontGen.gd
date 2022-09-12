extends Object

class_name BitmapFontGen

static func generate(config:BitmapFontGenConfig):
	
	if config.charmap.get_height() < config.height:
		assert(false)
	
	var font:BitmapFont = BitmapFont.new()
	font.height = config.height
	
	font.add_texture(config.charmap)
	var texture_width:int = config.charmap.get_width()
	
	var xpos:int = 0
	
	for code in config.unicode_order:
		if xpos >= texture_width:
			assert(false)
		
		var width:int = config.width
		if config.width_exceptions.has(code):
			width = config.width_exceptions[code] as int
		
		font.add_char(code, 0, Rect2(xpos, 0, width, config.height))
		
		xpos += width + config.seperate
	
	var theme:Theme = Theme.new()
	theme.default_font = font
	
	ResourceSaver.save(config.resource_save_path, theme)
