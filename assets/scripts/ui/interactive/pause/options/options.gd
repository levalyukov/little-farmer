extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var change_language = get_node("/root/"+main+"/UI/Windows/Options/Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language")
@onready var button_container:VBoxContainer = $Panel/Main/HBoxContainer/VBoxContainer/Buttons/VBoxContainer
@onready var pages_container:VBoxContainer = $Panel/Main/HBoxContainer/Pages/VBoxContainer
@onready var language_button:Control = $Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language/MarginContainer/Label
@onready var exit_button:Control = $Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Exit/MarginContainer/Label
@onready var anim:AnimationPlayer = $AnimationPlayer

@onready var graphic_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/GraphicSection
@onready var vsync:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/Container/VSyncMargin/VSyncButton
@onready var fullscreen:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/Container/FullScreenMargin/FullScreenButton
@onready var fps_limit:OptionButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/Container/FPSLimitMargin/HBoxContainer/MarginContainer/OptionButton

@onready var sounds_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection 
@onready var general_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/GeneralVolumeMargin/HBoxContainer/VBoxContainer/GeneralVolumeLabel
@onready var general_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/GeneralVolumeMargin/HBoxContainer/VBoxContainer/GeneralVolumeSlider
@onready var music_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/MusicVolumeMargin/HBoxContainer/VBoxContainer/MusicVolumeLabel
@onready var music_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/MusicVolumeMargin/HBoxContainer/VBoxContainer/MusicVolumeSlider
@onready var nature_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/NatureVolumeMargin/HBoxContainer/VBoxContainer/NatureVolumeLabel
@onready var nature_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/NatureVolumeMargin/HBoxContainer/VBoxContainer/NatureVolumeSlider
@onready var radio_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/RadioVolumeMargin/HBoxContainer/VBoxContainer/RadioVolumeLabel
@onready var radio_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/RadioVolumeMargin/HBoxContainer/VBoxContainer/RadioVolumeSlider


@onready var control_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/ControlSection

var opened:bool = false

func _ready():
	window()

func open() -> void:
	anim.play("open")
	opened = true
	if !check_path():
		var data_menu = get_node("/root/"+main+"/GameData")
		if data_menu:
			if data_menu.has_method('config_new'):
				data_menu.config_new()
				data_menu.config_load()

	if main == "MainMenu":
		var options = get_node("/root/"+main)
		if options:
			options.clicked = true

func close() -> void:
	anim.play("close")
	opened = false
	if main == "MainMenu":
		var options = get_node("/root/"+main)
		if options:
			options.clicked = false
	
func window():
	visible = opened

func _process(_delta):
	if visible:
		if sounds_section.visible:
			general_sound_label.text = str(general_sound_slider.value)+"%"
			music_sound_label.text = str(music_sound_slider.value)+"%"
			nature_sound_label.text = str(nature_sound_slider.value)+"%"
			radio_sound_label.text = str(radio_sound_slider.value)+"%"

func set_values(content:Dictionary) -> void:
	if content != {}:
		# Graphic
		if content.has("graphic"):
			if content['graphic'].has("fps_limit"):
				GameConfig.fps_limit = content['graphic']['fps_limit']
				fps_limit.selected = content['graphic']['fps_limit']
			if content['graphic'].has("fullscreen"):
				GameConfig.fullscreen = content['graphic']['fullscreen']
				fullscreen.button_pressed = content['graphic']['fullscreen']
			if content['graphic'].has("v-sync"):
				GameConfig.vsync = content['graphic']['v-sync']
				vsync.button_pressed = content['graphic']['v-sync']
		# Sound
		if content.has("sounds"):
			if content['sounds'].has("general"):
				GameConfig.general = content['sounds']['general']
				general_sound_slider.value = content['sounds']['general']
			if content['sounds'].has("music"):
				GameConfig.music = content['sounds']['music']
				music_sound_slider.value = content['sounds']['music']
			if content['sounds'].has("nature"):
				GameConfig.nature = content['sounds']['nature']
				nature_sound_slider.value = content['sounds']['nature']
			if content['sounds'].has("radio"):
				GameConfig.radio = content['sounds']['radio']
				radio_sound_slider.value = content['sounds']['radio']

func _saving() -> void:
	# Graphic
	GameConfig.fps_limit = fps_limit.selected
	GameConfig.fullscreen = fullscreen.button_pressed
	GameConfig.vsync = vsync.button_pressed
	# Music
	GameConfig.general = int(general_sound_slider.value)
	GameConfig.music = int(music_sound_slider.value)
	GameConfig.nature = int(nature_sound_slider.value)
	GameConfig.radio = int(radio_sound_slider.value)

# -- -- --
# Buttons
# -- -- --
func _on_graphic_button_pressed():
	graphic_section.visible = true
	sounds_section.visible = false
	control_section.visible = false

func _on_sound_button_pressed():
	graphic_section.visible = false
	sounds_section.visible = true
	control_section.visible = false

func _on_control_pressed():
	graphic_section.visible = false
	sounds_section.visible = false
	control_section.visible = true
# -- -- --

func _on_save_changes_button_pressed():
	var data_game = get_node("/root/"+main)
	var data_menu = get_node("/root/"+main+"/GameData")
	var blur_menu = get_node("/root/"+main+"/Blur")
	_saving()
	close()
	if blur_menu:
		blur_menu.blur(false)
	if data_game:
		if data_game.has_method('config_save'):
			data_game.config_save()
			pause.open()
			GameConfig.apply()
	if data_menu:
		if data_menu.has_method('config_save'):
			data_menu.config_save()
			GameConfig.apply()

func check_path() -> bool:
	var path = DirAccess.open('user://.game')
	var file = FileAccess.open('user://.game/config.json', FileAccess.READ)
	if path:
		if file:
			return true
	return false