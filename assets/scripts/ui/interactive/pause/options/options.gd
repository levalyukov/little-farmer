extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var change_language = get_node("/root/"+main+"/User Interface/Windows/Options/Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language")
@onready var button_container:VBoxContainer = $Panel/Main/HBoxContainer/VBoxContainer/Buttons/VBoxContainer
@onready var pages_container:VBoxContainer = $Panel/Main/HBoxContainer/Pages/VBoxContainer
@onready var language_button:Control = $Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language/MarginContainer/Label
@onready var exit_button:Control = $Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Exit/MarginContainer/Label
@onready var anim:AnimationPlayer = $AnimationPlayer

@onready var graphic_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/GraphicSection
@onready var vsync:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/Container/VSyncMargin/VSyncButton
@onready var fullscreen:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/Container/FullScreenMargin/FullScreenButton
@onready var fps_limit:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/Container/FPSLimitMargin/FPSLimitButton

@onready var sounds_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection 
@onready var general_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/GeneralVolumeMargin/HBoxContainer/VBoxContainer/GeneralVolumeLabel
@onready var general_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/GeneralVolumeMargin/HBoxContainer/VBoxContainer/GeneralVolumeSlider
@onready var music_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/MusicVolumeMargin/HBoxContainer/VBoxContainer/MusicVolumeLabel
@onready var music_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/MusicVolumeMargin/HBoxContainer/VBoxContainer/MusicVolumeSlider
@onready var nature_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/NatureVolumeMargin/HBoxContainer/VBoxContainer/NatureVolumeLabel
@onready var nature_sound_slider:HSlider =$Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/Container/NatureVolumeMargin/HBoxContainer/VBoxContainer/NatureVolumeSlider

@onready var control_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/ControlSection

var opened:bool = false

func _ready():
	window()

func open() -> void:
	anim.play("open")
	opened = true
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
	

# 
func get_vsync() -> bool:
	return vsync.button_pressed

func get_fullscreen() -> bool:
	return fullscreen.button_pressed

func get_fps_limit() -> bool:
	return fps_limit.button_pressed

func get_general_sound() -> int:
	return round(general_sound_slider.value)

func get_music_sound() -> int:
	return round(music_sound_slider.value)

func get_nature_sound() -> int:
	return round(nature_sound_slider.value)

#
#	func _on_v_sync_button_toggled(toggled_on:bool):
#		pass#print(toggled_on)
