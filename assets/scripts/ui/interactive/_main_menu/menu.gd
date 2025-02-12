extends MarginContainer

@onready var main = str(get_tree().root.get_child(1).name)
@onready var options:Control = $Menu/Options
@onready var blackout:Control = $Blackout
@onready var blur:Control = $Blur

@onready var credits:Label = $MarginContainer/MainContainer/Content/Credits
var clicked:bool = false

func _ready():
	blackout.blackout(false)
	credits.text = "v" + ProjectSettings.get_setting("application/config/version") + "\n(C) Studio Miroro"

func _on_continue_button_pressed():
	if !clicked:
		if !blur.state:
			blackout.blackout(true)
			GameLoader.mode = true
			GameLoader.start = false
			blackout.change_scene("res://levels/farm.tscn")

func _on_new_game_button_pressed():
	if !clicked:
		if !blur.state:
			blackout.blackout(true)
			GameLoader.mode = false
			GameLoader.start = true
			blackout.change_scene("res://levels/farm.tscn")

func _on_options_button_pressed():
	if !clicked:
		blur.blur(true)
		options.open()

func _on_exit_button_pressed():
	if !clicked:
		blackout.blackout(true)
		await get_tree().create_timer(1).timeout
		get_tree().quit()
