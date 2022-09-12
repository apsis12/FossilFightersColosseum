extends Node2D

func push_vivo(vivo:Vivosaur):
	$Element.texture = load("res://Assets/Icon/element/" + VivoDBEntry.str_element(vivo.dbentry.element) + "_Medal.png")
	$Name.text = vivo.dbentry.label
	$TypeSize.text = VivoDBEntry.str_range(vivo.dbentry.rnge) + " (" + VivoDBEntry.str_type(vivo.dbentry.type) + ") / " + VivoDBEntry.str_size(vivo.dbentry.size)
	$Index.text = str(vivo.dbentry.index).pad_zeros(3)
