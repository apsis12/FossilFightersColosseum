extends Node

var music_volume:int = 100 setget set_music_volume, get_music_volume
func set_music_volume(new:int):
	music_volume = int(clamp(new, 0, 100))
func get_music_volume():
	return music_volume

var sfx_volume:int = 100 setget set_sfx_volume, get_sfx_volume
func set_sfx_volume(new:int):
	sfx_volume = int(clamp(new, 0, 100))
func get_sfx_volume():
	return sfx_volume
