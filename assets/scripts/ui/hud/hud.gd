extends Control

# =============================================================================================
# (hud.gd)
# =============================================================================================
# Скрипт поведения HUD.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Инициализация кнопок
# - Взаимодействия с менеджерами сцены
#
# ЗАВИСИМОСТИ:
# - UIManager - взаимодействие с пользовательским интерфейсом
# - AnimationPlayer - для плавного появления и скрытие интерфейса методом изменении модуляции
#
# =============================================================================================

@onready var anim: AnimationPlayer = $Animation

@onready var destroy: Button = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Destroy/Main/Button
@onready var farming: Button = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Farming/Main/Button
@onready var watering: Button = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Watering/Main/Button
@onready var harvest: Button = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Harvest/Main/Button
@onready var build: Button = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Build/Main/Button
@onready var destroy_icon: TextureRect = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Destroy/Main/Margin/Icon
@onready var farming_icon: TextureRect = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Farming/Main/Margin/Icon
@onready var watering_icon: TextureRect = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Watering/Main/Margin/Icon
@onready var harvest_texture: TextureRect = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Harvest/Main/Margin/Icon
@onready var build_icon: TextureRect = $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Build/Main/Margin/Icon

@onready var debug:Label = $Main/Bars/Debug/Label

const ICONS: Dictionary = {
	0: preload("res://assets/resources/ui/interactive/hud/tools/trash.png"),
	1: preload("res://assets/resources/ui/interactive/hud/tools/hoe.png"),
	2: preload("res://assets/resources/ui/interactive/hud/tools/watering_can.png"),
	3: preload("res://assets/resources/ui/interactive/hud/tools/sickle.png"),
	4: preload("res://assets/resources/ui/interactive/hud/tools/hammer.png")
}

var debug_mode:bool = true


func _ready() -> void:
	self.visible = true

	set_process(true) if debug_mode else set_process(false)

	anim.animation_finished.connect(
		func(animation_name: String) -> void:
			if animation_name != "show":
				UIManager.ui_remove(self)
	)

	anim.play("show")
	_button_init()

func _process(_delta:float) -> void:
	if debug_mode:
		debug.text = 'FPS: ' + str(Engine.get_frames_per_second()) 				\
		+ '\nRAM: %d MB' % (OS.get_static_memory_usage() / 1024 / 1024) 		\
		+ "\nCPU: " + str(Performance.get_monitor(Performance.TIME_PROCESS)) 	\
		+ "\nVulkan: " + str(RenderingServer.get_video_adapter_api_version())

func _button_init() -> void:
	destroy_icon.texture = ICONS[0] 	if ICONS[0] is CompressedTexture2D else null
	farming_icon.texture = ICONS[1] 	if ICONS[1] is CompressedTexture2D else null
	watering_icon.texture = ICONS[2] 	if ICONS[2] is CompressedTexture2D else null
	harvest_texture.texture = ICONS[3] 	if ICONS[3] is CompressedTexture2D else null
	build_icon.texture = ICONS[4] 		if ICONS[4] is CompressedTexture2D else null

	destroy.pressed.connect(
		func() -> void:
			if UIManager.build:
				UIManager.build.grid_add(UIManager.build.GridModes.DESTROY)
			_close()
	)
	
	farming.pressed.connect(
		func() -> void:
			if UIManager.build:
				UIManager.build.grid_add(UIManager.build.GridModes.FARMING)
			_close()
	)
	watering.pressed.connect(
		func() -> void:
			if UIManager.build:
				UIManager.build.grid_add(UIManager.build.GridModes.WATERING)
			_close()
	)
	
	harvest.pressed.connect(
		func() -> void:
			if UIManager.build:
				UIManager.build.grid_add(UIManager.build.GridModes.HARVESTING)
			_close()
	)
	
	build.pressed.connect(func() -> void: _close())
	
	destroy.pressed.connect(UIManager.button_pressed)
	farming.pressed.connect(UIManager.button_pressed)
	watering.pressed.connect(UIManager.button_pressed)
	harvest.pressed.connect(UIManager.button_pressed)
	build.pressed.connect(UIManager.button_pressed)

	destroy.mouse_entered.connect(UIManager.button_hovered)
	farming.mouse_entered.connect(UIManager.button_hovered)
	watering.mouse_entered.connect(UIManager.button_hovered)
	harvest.mouse_entered.connect(UIManager.button_hovered)
	build.mouse_entered.connect(UIManager.button_hovered)

	destroy.mouse_exited.connect(UIManager.button_exited)
	farming.mouse_exited.connect(UIManager.button_exited)
	watering.mouse_exited.connect(UIManager.button_exited)
	harvest.mouse_exited.connect(UIManager.button_exited)
	build.mouse_exited.connect(UIManager.button_exited)


func _close() -> void:
	anim.play("hide")
