extends Control

@onready var anim: AnimationPlayer = $Animation

@onready var graphic: Button = $Menu/Main/HBox/Panel/VBox/MainContent/Margin/SectionsButtons/GraphicButton
@onready var sounds: Button = $Menu/Main/HBox/Panel/VBox/MainContent/Margin/SectionsButtons/SoundButton
@onready var control: Button = $Menu/Main/HBox/Panel/VBox/MainContent/Margin/SectionsButtons/ControlButton
@onready var language: Button = $Menu/Main/HBox/Panel/VBox/Margin/MenuButtons/ChangeLanguage
@onready var confirm: Button = $Menu/Main/HBox/Panel/VBox/Margin/MenuButtons/Confirm

@onready var graphic_section: ScrollContainer = $Menu/Main/HBox/Content/Graphic
@onready var graphic_vsync: Button = $Menu/Main/HBox/Content/Graphic/Margin/Container/VSync/VSync
@onready var graphic_fullscreen: Button = $Menu/Main/HBox/Content/Graphic/Margin/Container/FullScreen/FullScreen
@onready var graphic_fps: OptionButton = $Menu/Main/HBox/Content/Graphic/Margin/Container/FPS/HBox/Margin/OptionButton

@onready var sounds_section: ScrollContainer = $Menu/Main/HBox/Content/Sounds
@onready var sounds_general_label: Label = $Menu/Main/HBox/Content/Sounds/Margin/Container/General/HBox/VBox/Label
@onready var sounds_general_slider: HSlider = $Menu/Main/HBox/Content/Sounds/Margin/Container/General/HBox/VBox/Slider
@onready var sounds_music_label: Label = $Menu/Main/HBox/Content/Sounds/Margin/Container/Music/HBox/VBox/Label
@onready var sounds_music_slider: HSlider = $Menu/Main/HBox/Content/Sounds/Margin/Container/Music/HBox/VBox/Slider
@onready var sounds_nature_label: Label = $Menu/Main/HBox/Content/Sounds/Margin/Container/Nature/HBox/VBox/Label
@onready var sounds_nature_slider: HSlider = $Menu/Main/HBox/Content/Sounds/Margin/Container/Nature/HBox/VBox/Slider
@onready var sounds_radio_label: Label = $Menu/Main/HBox/Content/Sounds/Margin/Container/Radio/HBox/VBox/Label
@onready var sounds_radio_slider: HSlider = $Menu/Main/HBox/Content/Sounds/Margin/Container/Radio/HBox/VBox/Slider

@onready var control_section: ScrollContainer = $Menu/Main/HBox/Content/Control
@onready var control_move: OptionButton = $Menu/Main/HBox/Content/Control/Margin/Container/MoveType/HBox/Margin/Button


func _ready() -> void:
	GameData.settings_load()
	_init_buttons()
	_init_values()
	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				if get_tree().current_scene.name != "MainMenu":
					UIManager.add_ui(UIManager.MENUS.PAUSE)
				UIManager.remove_ui(self)
	)

	UIManager.blur.blur(true)
	anim.play("show")
	self.visible = true


func _init_buttons() -> void:
	graphic.pressed.connect(_change_section.bind(0))
	graphic.pressed.connect(UIManager.button_pressed)
	graphic.mouse_entered.connect(UIManager.button_hovered)
	graphic.mouse_exited.connect(UIManager.button_exited)

	sounds.pressed.connect(_change_section.bind(1))
	sounds.pressed.connect(UIManager.button_pressed)
	sounds.mouse_entered.connect(UIManager.button_hovered)
	sounds.mouse_exited.connect(UIManager.button_exited)

	control.pressed.connect(_change_section.bind(2))
	control.pressed.connect(UIManager.button_pressed)
	control.mouse_entered.connect(UIManager.button_hovered)
	control.mouse_exited.connect(UIManager.button_exited)

	confirm.pressed.connect(_close)
	confirm.pressed.connect(UIManager.button_pressed)
	confirm.mouse_entered.connect(UIManager.button_hovered)
	confirm.mouse_exited.connect(UIManager.button_exited)

	language.pressed.connect(_change_language)
	language.pressed.connect(UIManager.button_pressed)
	language.mouse_entered.connect(UIManager.button_hovered)
	language.mouse_exited.connect(UIManager.button_exited)


func _init_values() -> void:
	_init_graphic()
	_init_sounds()
	_init_control()


func _init_graphic() -> void:
	graphic_vsync.button_pressed = Settings.vsync
	graphic_fullscreen.button_pressed = Settings.fullscreen
	graphic_fps.selected = Settings.fps
	graphic_vsync.pressed.connect(UIManager.button_pressed)
	graphic_vsync.mouse_entered.connect(UIManager.button_hovered)
	graphic_vsync.mouse_exited.connect(UIManager.button_exited)
	graphic_fullscreen.pressed.connect(UIManager.button_pressed)
	graphic_fullscreen.mouse_entered.connect(UIManager.button_hovered)
	graphic_fullscreen.mouse_exited.connect(UIManager.button_exited)
	graphic_fps.pressed.connect(UIManager.button_pressed)
	graphic_fps.mouse_entered.connect(UIManager.button_hovered)
	graphic_fps.mouse_exited.connect(UIManager.button_exited)

	graphic_vsync.toggled.connect(
		func(value: bool) -> void:
			Settings.vsync = value
			ProjectSettings.set_setting("display/window/vsync/vsync_mode", 1 if value else 0)
	)

	graphic_fullscreen.toggled.connect(
		func(value: bool) -> void:
			Settings.fullscreen = value
			get_window().mode = Window.MODE_FULLSCREEN if value else Window.MODE_WINDOWED
	)

	graphic_fps.item_selected.connect(
		func(index: int) -> void:
			Settings.fps = index
			match index:
				0:
					Engine.max_fps = 30
				1:
					Engine.max_fps = 60
				_:
					Engine.max_fps = Settings.MAX_FPS
	)


func _init_sounds() -> void:
	sounds_general_label.text = str(Settings.general_volume) + "%"
	sounds_music_label.text = str(Settings.music_volume) + "%"
	sounds_nature_label.text = str(Settings.nature_volume) + "%"
	sounds_radio_label.text = str(Settings.radio_volume) + "%"

	sounds_general_slider.value = Settings.general_volume
	sounds_music_slider.value = Settings.music_volume
	sounds_nature_slider.value = Settings.nature_volume
	sounds_radio_slider.value = Settings.radio_volume

	sounds_general_slider.drag_started.connect(UIManager.button_pressed)
	sounds_music_slider.drag_started.connect(UIManager.button_pressed)
	sounds_nature_slider.drag_started.connect(UIManager.button_pressed)
	sounds_radio_slider.drag_started.connect(UIManager.button_pressed)

	sounds_general_slider.mouse_entered.connect(UIManager.button_hovered)
	sounds_music_slider.mouse_entered.connect(UIManager.button_hovered)
	sounds_nature_slider.mouse_entered.connect(UIManager.button_hovered)
	sounds_radio_slider.mouse_entered.connect(UIManager.button_hovered)

	sounds_general_slider.mouse_exited.connect(UIManager.button_exited)
	sounds_music_slider.mouse_exited.connect(UIManager.button_exited)
	sounds_nature_slider.mouse_exited.connect(UIManager.button_exited)
	sounds_radio_slider.mouse_exited.connect(UIManager.button_exited)

	sounds_general_slider.value_changed.connect(
		func(value: float) -> void:
			Settings.general_volume = int(value)
			sounds_general_label.text = str(value) + "%"
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Master"), 20.0 * log(clamp(value / 100.0, 0.001, 1.0)) / log(10.0)
			)
	)

	sounds_music_slider.value_changed.connect(
		func(value: float) -> void:
			Settings.music_volume = int(value)
			sounds_music_label.text = str(value) + "%"
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Music"), 20.0 * log(clamp(value / 100.0, 0.001, 1.0)) / log(10.0)
			)
	)

	sounds_nature_slider.value_changed.connect(
		func(value: float) -> void:
			Settings.nature_volume = int(value)
			sounds_nature_label.text = str(value) + "%"
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Nature"), 20.0 * log(clamp(value / 100.0, 0.001, 1.0)) / log(10.0)
			)
	)

	sounds_radio_slider.value_changed.connect(
		func(value: float) -> void:
			Settings.radio_volume = int(value)
			sounds_radio_label.text = str(value) + "%"
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Radio"), 20.0 * log(clamp(value / 100.0, 0.001, 1.0)) / log(10.0)
			)
	)


func _init_control() -> void:
	control_move.pressed.connect(
		func() -> void:
			SoundManager.play_sound("ui/click")
			if is_instance_valid(UIManager.cursor):
				UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
	)

	control_move.item_selected.connect(func(value: int) -> void: Settings.movement_type = value)
	control_move.mouse_entered.connect(UIManager.button_hovered)
	control_move.mouse_exited.connect(UIManager.button_exited)
	control_move.selected = Settings.movement_type


func _change_section(section_id: int) -> void:
	match section_id:
		0:  # Graphic
			graphic_section.visible = true
			sounds_section.visible = false
			control_section.visible = false
		1:  # Sounds
			graphic_section.visible = false
			sounds_section.visible = true
			control_section.visible = false
		2:  # Control
			graphic_section.visible = false
			sounds_section.visible = false
			control_section.visible = true


func _change_language() -> void:
	Settings.language = (Settings.language + 1) % Settings.LANGUAGES_KEYS.size()
	TranslationServer.set_locale(Settings.LANGUAGES_KEYS[Settings.language])


func _close() -> void:
	GameData.settings_save()
	UIManager.blur.blur(false)
	anim.play("hide")
