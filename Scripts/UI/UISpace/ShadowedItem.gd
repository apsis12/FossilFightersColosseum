extends UIItem
class_name ShadowedItem

var shadow :Sprite
export var height :float = 0.0 setget set_height
export var shadow_color :Color = Color.black setget set_shadow_color
export var shadow_angle :float = -PI/4

func set_height(new:float):
	height = new
	offset.y = -height
	shadow.position = 0.5 * height * Vector2.RIGHT.rotated(shadow_angle)

#if null, shadow will be generated
export var shadow_texture:Texture = null setget set_shadow_texture

func _init():
	init_shadow()

func generate_shadow():
	if texture != null:
		
		if shadow_texture == null:
			#get texture data
			var data:Image = texture.get_data().duplicate()
			data.lock()
			
			#get texture shape
			for y in data.get_height():
				for x in data.get_width():
					#set all pixels white but keep alpha component
					data.set_pixel(x, y, Color(1, 1, 1, data.get_pixel(x, y).a))
			
			data.unlock()
			
			#dump data into new texture
			var tex :ImageTexture = ImageTexture.new()
			tex.create_from_image(data, 0)
			
			#finalize
			shadow.set_texture(tex)
			
			#clean up
			data.free()
			tex.free()
		else:
			set_shadow_texture(shadow_texture)

func init_shadow():
	if shadow != null:
		shadow.free()
	shadow = Sprite.new()
	shadow.set_name("shadow")
	set_shadow_color(shadow_color)
	shadow.show_behind_parent = true
	add_child(shadow)

func set_texture(new:Texture):
	texture = new
	generate_shadow()

func set_shadow_color(new:Color):
	shadow_color = new
	if shadow_texture == null:
		shadow.set_self_modulate(shadow_color)

func set_shadow_texture(new:Texture):
	shadow_texture = new
	shadow.set_texture(shadow_texture)
