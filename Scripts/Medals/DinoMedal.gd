extends ShadowedItem

class_name DinoMedal

var tween: Tween
var glint:AnimatedSprite
var glint_timer:Timer

func _init(v:Vivosaur = null):
	operative = false
	mouse_enabled = false
	
	set_shadow_texture(preload("res://Assets/VivoView/medals/Dino_Medal_Shadow.png"))
	
	tween = Tween.new()
	add_child(tween)
	
	glint = AnimatedSprite.new()
	glint.frames = preload("res://Scripts/Medals/medal_glint_spriteframes.tres")
	add_child(glint)
	
	glint_timer = Timer.new()
	glint_timer.wait_time = 2.0
	glint_timer.connect("timeout", self, "_on_glint_timer_timeout")
	add_child(glint_timer)
	
	set_vivo(v)

var vivo: Vivosaur = null setget set_vivo

func set_vivo(n:Vivosaur):
	if vivo != null:
		vivo.disconnect("index_changed", self, "fetch_texture")
	vivo = n
	if vivo != null:
		vivo.connect("index_changed", self, "fetch_texture")
		fetch_texture()

func set_height(new):
	height = new
	offset.y = -new
	glint.offset.y = -new
	shadow.position = 0.5 * new * Vector2.RIGHT.rotated(shadow_angle)

func fetch_texture():
	texture = load(vivo.get_asset_path() + "DinoMedals/" + vivo.dbentry.label + ".png")

#GLINT
func play_glint(persistant:bool = false):
	glint.play("radial")
	yield(glint, "animation_finished")
	glint.play("diagonal")
	if persistant:
		glint_timer.start()

func _on_glint_timer_timeout():
	glint.set_frame(0)
	glint.play("diagonal")

func stop_glint():
	glint_timer.stop()

func enter():
	z_index = 1
	tween.interpolate_property(self, "height", height, 5.0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func leave():
	z_index = 0
	tween.interpolate_property(self, "height", height, 0.0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func select():
	tween.interpolate_property(self, "height", height, 15.0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
