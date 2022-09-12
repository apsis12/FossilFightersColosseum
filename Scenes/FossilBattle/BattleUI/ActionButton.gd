extends UIItem

var texture_normal:StreamTexture
export var texture_focus:StreamTexture

func enter():
	texture = texture_focus

func leave():
	texture = texture_normal

func _ready():
	texture_normal = texture
