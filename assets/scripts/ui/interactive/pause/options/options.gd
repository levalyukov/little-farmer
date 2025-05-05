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
@onready var vsync:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/MarginContainer/Container/VSyncMargin/VSyncButton
@onready var fullscreen:CheckButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/MarginContainer/Container/FullScreenMargin/FullScreenButton
@onready var fps_limit:OptionButton = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/MarginContainer/Container/FPSLimitMargin/HBoxContainer/MarginContainer/OptionButton

@onready var sounds_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection 
@onready var general_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/GeneralVolumeMargin/HBoxContainer/VBoxContainer/GeneralVolumeLabel
@onready var general_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/GeneralVolumeMargin/HBoxContainer/VBoxContainer/GeneralVolumeSlider
@onready var music_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/MusicVolumeMargin/HBoxContainer/VBoxContainer/MusicVolumeLabel
@onready var music_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/MusicVolumeMargin/HBoxContainer/VBoxContainer/MusicVolumeSlider
@onready var nature_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/NatureVolumeMargin/HBoxContainer/VBoxContainer/NatureVolumeLabel
@onready var nature_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/NatureVolumeMargin/HBoxContainer/VBoxContainer/NatureVolumeSlider
@onready var radio_sound_label:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/RadioVolumeMargin/HBoxContainer/VBoxContainer/RadioVolumeLabel
@onready var radio_sound_slider:HSlider = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/RadioVolumeMargin/HBoxContainer/VBoxContainer/RadioVolumeSlider
@onready var control_section:ScrollContainer = $Menu/Main/HBoxContainer/PageBackground/ControlSection

# --- --- ---

@onready var buttonGraphic:Button = $Menu/Main/HBoxContainer/Panel/VBoxContainer/MainContent/MarginContainer/SectionsButtons/GraphicButton
@onready var buttonSounds:Button = $Menu/Main/HBoxContainer/Panel/VBoxContainer/MainContent/MarginContainer/SectionsButtons/SoundButton
@onready var buttonControl:Button = $Menu/Main/HBoxContainer/Panel/VBoxContainer/MainContent/MarginContainer/SectionsButtons/ControlButton
@onready var buttonLanguage:Button = $Menu/Main/HBoxContainer/Panel/VBoxContainer/MarginContainer/MenuButtons/ChangeLanguageButton
@onready var buttonSaveSettings:Button = $Menu/Main/HBoxContainer/Panel/VBoxContainer/MarginContainer/MenuButtons/SaveChangesButton

var buttonGraphicText:String = tr('options.graphic')
var buttonSoundsText:String = tr('options.sounds')
var buttonControlText:String = tr('options.control')
var buttonLanguageText:String = tr('options.game_language')
var buttonSaveSettingsText:String = tr('options.save_changes')

# --- --- ---

# Graphic Section
@onready var vSyncButton:Button = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/MarginContainer/Container/VSyncMargin/VSyncButton
@onready var fullModeButton:Button = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/MarginContainer/Container/FullScreenMargin/FullScreenButton
@onready var fpsLimit:Label = $Menu/Main/HBoxContainer/PageBackground/GraphicSection/MarginContainer/Container/FPSLimitMargin/HBoxContainer/MarginContainer/Label
var vSyncText:String = tr('options.graphic.vsync')
var fullModeText:String = tr('options.graphic.fullScreen')
var fpsLimitText:String = tr('options.graphic.FPSLimit')
var fpsLimitOff:String = tr('options.graphic.FPSLimit_off')

# Sounds Section
@onready var soundsOverall:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/GeneralVolumeMargin/HBoxContainer/MarginContainer/Label
@onready var soundsMusic:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/MusicVolumeMargin/HBoxContainer/MarginContainer/Label
@onready var soundsNature:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/NatureVolumeMargin/HBoxContainer/MarginContainer/Label
@onready var soundsRadio:Label = $Menu/Main/HBoxContainer/PageBackground/SoundVolumeSection/MarginContainer/Container/RadioVolumeMargin/HBoxContainer/MarginContainer/Label

var soundsOverallText:String = tr('options.sounds.overall')
var soundsMusicText:String = tr('options.sounds.music')
var soundsNatureText:String = tr('options.sounds.nature')
var soundsRadioText:String = tr('options.sounds.radio')

# Control Section
@onready var controlMovementLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/MovementButton/MarginContainer/HBoxContainer/InputsName
@onready var controlInteractLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/InteractiveButton/MarginContainer/HBoxContainer/InputsName
@onready var controlInventoryLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/InventoryButton/MarginContainer/HBoxContainer/InputsName
@onready var controlCameraZoomLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/CameraZoomButton/MarginContainer/HBoxContainer/InputsName
@onready var controlScreenshotLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/ScreenshotButton/MarginContainer/HBoxContainer/InputsName

@onready var controlMovementInputLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/MovementButton/MarginContainer/HBoxContainer/Inputs
@onready var controlInteractInputLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/InteractiveButton/MarginContainer/HBoxContainer/Inputs
@onready var controlInventoryInputLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/InventoryButton/MarginContainer/HBoxContainer/Inputs
@onready var controlCameraZoomInputLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/CameraZoomButton/MarginContainer/HBoxContainer/Inputs
@onready var controlScreenshotInputLabel:Label = $Menu/Main/HBoxContainer/PageBackground/ControlSection/MarginContainer/Container/ScreenshotButton/MarginContainer/HBoxContainer/Inputs

var controlMovementText:String = tr('options.control.movement')
var controlInteractText:String = tr('options.control.interact')
var controlInventoryText:String = tr('options.control.inventory')
var controlCameraZoomText:String = tr('options.control.zoom')
var controlScreenshotText:String = tr('options.control.screenshot')

var controlMovementInputText:String = tr('options.control.movement_input')
var controlInteractInputText:String = tr('options.control.interact_input')
var controlInventoryInputText:String = tr('options.control.inventory_input')
var controlCameraZoomInputText:String = tr('options.control.zoom_input')
var controlScreenshotInputText:String = tr('options.control.screenshot_input')

# --- --- ---
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
	else:
		if get_node("/root/"+main+"/UI/Decorative/Blur"):
			if get_node("/root/"+main+"/UI/Decorative/Blur").state:
				pause.open()
	
func window():
	visible = opened
	if pause:
		pause.other_menu = opened

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
		if content.has('language'):
			GameConfig.language = content['language']
			match main:
				'MainMenu':
					var languageButton = get_node('/root/'+main+'/Menu/Options/Menu/Main/HBoxContainer/Panel/VBoxContainer/MarginContainer/MenuButtons/ChangeLanguageButton')
					languageButton.set_language(GameConfig.language)
				_:
					var languageButton = get_node('/root/'+main+'/UI/Interactive/Options/Menu/Main/HBoxContainer/Panel/VBoxContainer/MarginContainer/MenuButtons/ChangeLanguageButton')
					languageButton.set_language(GameConfig.language)

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
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_sound_button_pressed():
	graphic_section.visible = false
	sounds_section.visible = true
	control_section.visible = false
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_control_pressed():
	graphic_section.visible = false
	sounds_section.visible = false
	control_section.visible = true
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_graphic_button_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

func _on_sound_button_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

func _on_control_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

# -- -- --

func _on_save_changes_button_pressed():
	var data_game = get_node("/root/"+main)
	var data_menu = get_node("/root/"+main+"/GameData")
	var blur_menu = get_node("/root/"+main+"/Blur")
	_saving()
	close()
	GameConfig.apply()
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
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func check_path() -> bool:
	var path = DirAccess.open('user://game')
	var file = FileAccess.open('user://game/config.json', FileAccess.READ)
	if path:
		if file:
			return true
	return false

func _on_v_sync_button_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

func _on_full_screen_button_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

func _on_option_button_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

func _on_option_button_pressed():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_full_screen_button_pressed():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_v_sync_button_pressed():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_option_button_item_selected(_index:int):
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()

func _on_graphic_button_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)	

func _on_control_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)	

func _on_sound_button_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)	

func _on_save_changes_button_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)	

func _on_save_changes_button_mouse_entered():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.ACTIVE)	

func _on_full_screen_button_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)	

func _on_v_sync_button_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)		

func _on_option_button_mouse_exited():
	if main == "MainMenu":
		var cursor = get_node('/root/'+main+'/Cursor')
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)	
