extends Node2D

signal text_changed()

func _ready():
	if text.length() != 0 and get_child_count() == 0:
		parse_and_generate()

export var text : String = "text here" setget set_text
func set_text(val:String):
	text = val
	var ret = parse_and_generate()
	emit_signal("text_changed")
	return ret

export var default_color : Color = Color.black setget set_default_color
func set_default_color(val:Color):
	default_color = val
	parse_and_generate()

export var initial_color : Color = Color.black setget set_initial_color
func set_initial_color(val:Color):
	initial_color = val
	parse_and_generate()

export var theme:Theme = preload("res://Fonts/Resource/FFBasicFont.tres") setget set_theme
func set_theme(val:Theme):
	assert(val.get_default_font() is BitmapFont, "Property 'default_font' must be of type BitmapFont")
	theme = val
	parse_and_generate()

#TEXT GENERATION
func parse_and_generate():
	pass

func clear():
	for i in get_children():
		remove_child(i)
		i.queue_free()

#HELPERS
func get_bitmap_font_pixel_width(raw:String):
	var width = 0
	for i in raw:
		width += theme.default_font.get_char_size(ord(i)).x
	return width

static func parse_words(raw:String):
	var words: PoolStringArray = []
	var current_word:String
	
	if not raw.ends_with(" "):
		raw += " "
	
	for i in raw:
		if i == ' ':
			words.append(current_word)
			current_word = ""
		else:
			current_word += i
	
	return words
