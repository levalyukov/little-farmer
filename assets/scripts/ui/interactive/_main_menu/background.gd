extends ColorRect

@onready var version:Label = $"../Main/Credits/Version"

const dark:Color = Color("222831")
const light:Color = Color("EEEEEE")

const evening:int = 18
const morning:int = 7

func _ready():
	background()

func background() -> void:
	if range(morning, evening).has(int(get_time().left(2))):
		color = light
		#version.modulate = dark
	else:
		color = dark
		#version.modulate = light

func get_time() -> String:
	return Time.get_time_string_from_system(false)

func get_gametime_status() -> String:
	if range(morning, evening).has(int(get_time().left(2))):
		return "light"
	else:
		return "dark"
