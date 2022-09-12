extends "res://Scripts/UI/BitMapText/BitmapTextElement.gd"
class_name BitmapRichText

export var width : float = 200 setget set_width
func set_width(val:float):
	width = clamp(val, 30.0, INF)
	parse_and_generate()

export var linespacing : float = 6.0 setget set_linespacing
func set_linespacing(val:float):
	linespacing = clamp(val, 0, INF)
	parse_and_generate()

func parse_and_generate():
	clear()
	var text_left : String = text
	var last_color : Color = initial_color
	
	while text_left.length() != 0:
		var line : BitmapTextLine = BitmapTextLine.new()
		line.set_name("line_" + str(get_child_count()))
		line.position.y = (theme.default_font.get_height() + linespacing) * get_child_count()
		line.set_default_color(default_color)
		line.set_length_limit(width)
		line.set_initial_color(last_color)
		text_left = line.set_text(text_left)
		add_child(line)
		last_color = line.get_ultimate_color()
		
		if line.get_displayed_text().length() == 0:
			push_warning("Single word exceeds max width, text parsing aborted.")
			break

func get_dimensions():
	var line_height:float = theme.default_font.get_height() + linespacing
	var dimensions:Vector2 = Vector2(0, line_height * get_child_count())
	var text_checker:Array = []
	
	for line in get_children():
		text_checker.append(line.get_actual_length())
	
	dimensions.x = text_checker.max() if text_checker.size() != 0 else 30.0
	
	return dimensions

func get_line(index:int) -> BitmapTextLine:
	return get_child(index) as BitmapTextLine

func get_last_line() -> BitmapTextLine:
	return get_line(get_child_count() - 1)

func get_length_of_last_line() -> int:
	return get_last_line().get_actual_length() if get_last_line() != null else 0
