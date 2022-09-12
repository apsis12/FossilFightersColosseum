extends "res://Scripts/UI/BitMapText/BitmapTextElement.gd"
class_name BitmapTextLine

export var length_limit : float = 0.0 setget set_length_limit
func set_length_limit(val:float):
	length_limit = clamp(val, 0, INF)
	parse_and_generate()
func is_length_limited():
	return length_limit != 0.0

func parse_and_generate():
	clear()
	var words : PoolStringArray = parse_words(text)
	var current_progress : String = ""
	var text_parsed : String = ""
	var modulation : Color = initial_color
	
	var text_block:Label = Label.new()
	text_block.theme = theme
	text_block.self_modulate = modulation
	
	for word in words:
		word = String(word)
		
		if ">" in word:
			var wordcpy : String = word
			
			if text_block.text.length() != 0:
				append_text_block(text_block, modulation, current_progress)
				current_progress += text_block.text
				text_block = Label.new()
			
			var envelope : Node = Node.new()
			
			while wordcpy.length() != 0:
				if wordcpy.begins_with(">"):
					wordcpy.erase(0,1)
					if wordcpy.begins_with("c"):
						wordcpy.erase(0,1)
						if wordcpy.begins_with("DEF"):
							modulation = default_color
							wordcpy.erase(0,3)
						elif wordcpy.begins_with("KEY"):
							modulation = Color("F71414")
							wordcpy.erase(0,3)
						elif wordcpy.begins_with("NAME"):
							modulation = Color("009400")
							wordcpy.erase(0,4)
						elif wordcpy.begins_with("BLACK"):
							modulation = Color.black
							wordcpy.erase(0,5)
						elif wordcpy.begins_with("WHITE"):
							modulation = Color.white
							wordcpy.erase(0,5)
						elif wordcpy.substr(0,6).is_valid_html_color():
							modulation = Color(wordcpy.substr(0,6))
							wordcpy.erase(0,6)
				else:
					var segment : String = wordcpy.substr(0,wordcpy.find(">")) if ">" in wordcpy else wordcpy + " "
					text_block.text += segment
					wordcpy.erase(0, text_block.text.length())
					append_text_block(text_block, modulation, current_progress, envelope)
					current_progress += segment
					text_block = Label.new()
			
			if is_length_limited() and get_bitmap_font_pixel_width(current_progress) > length_limit:
				return text.substr(text_parsed.length())
			else: #Unload 
				for i in envelope.get_children():
					envelope.remove_child(i)
					add_child(i)
			
			text_parsed += word + " "
			envelope.free()
		
		elif is_length_limited() and get_bitmap_font_pixel_width(current_progress + text_block.text + word + " ") > length_limit:
			append_text_block(text_block, modulation, current_progress)
			return text.substr((text_parsed).length())
		else:
			text_block.text += word + " "
			text_parsed += word + " "
	
	if not text_block.is_inside_tree() and text_block.text.length() != 0:
		append_text_block(text_block, modulation, current_progress)
	
	return ""

func append_text_block(text_block:Label, modulation:Color, current_progress:String, parent:Node = self):
	text_block.set_theme(theme)
	text_block.set_self_modulate(modulation)
	text_block.rect_position.x = get_bitmap_font_pixel_width(current_progress)
	parent.add_child(text_block)

func exceeds_length(length:float):
	return get_bitmap_font_pixel_width(text) > length

func get_ultimate_color():
	return get_child(get_child_count()-1).get_self_modulate() if get_child_count() != 0 else default_color

func get_displayed_text():
	var return_text : String = ""
	for i in get_children():
		return_text += i.get_text()
	return return_text

func get_actual_length():
	return get_bitmap_font_pixel_width(get_displayed_text())
