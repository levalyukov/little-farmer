extends Control

# =============================================================================================
# (pause.gd)
# =============================================================================================
# Скрипт меню паузы
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Открытие игровые настроек
# - Перенаправление на кнопку на формой заполнения бага
# - Сохранение и выход из игры
#
# ЗАВИСИМОСТИ:
# - Utils - вспомогательные методы
# - UIManager - взаимодействие с пользовательским интерфейсом
# - AnimationPlayer - для плавного появления и скрытие интерфейса методом изменении модуляции
#
# =============================================================================================

@onready var anim: AnimationPlayer = $Animation
@onready var resume: Button = $Main/Container/CountinueButtonMargin/CountinueButton
@onready var settings: Button = $Main/Container/SettingsButtonMargin/SettingsButton
@onready var report: Button = $Main/Container/ReportBugButtonMargin/ReportBugButton
@onready var exit: Button = $Main/Container/ExitButtonMargin/ExitButton


func _ready() -> void:
	_button_init()
	self.visible = false
	anim.animation_finished.connect(_anim_is_finished)
	open()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc") && abs(self.modulate.a) == 1.0:
		close()


func open() -> void:
	self.visible = true
	UIManager.blur.blur(true)
	anim.play("show")


func close() -> void:
	UIManager.ui_add(UIManager.MENUS.HUD)
	UIManager.blur.blur(false)
	anim.play("hide")


func _button_init() -> void:
	resume.pressed.connect(func() -> void: close())

	settings.pressed.connect(
		func() -> void:
			UIManager.ui_add(UIManager.MENUS.OPTIONS)
			UIManager.ui_remove(self)
	)

	report.pressed.connect(func() -> void: Utils.open_url("https://www.youtube.com/watch?v=gAsNvXDsrGA"))

	exit.pressed.connect(
		func() -> void:
			if is_instance_valid(UIManager.blackout):
				UIManager.blackout.anim.animation_finished.connect(
					func(animation_name: String) -> void:
						if animation_name != "show":
							GameData.save()
							get_tree().change_scene_to_file("res://levels/menu.tscn")
							UIManager.blur.blur(false)
							UIManager.ui_remove(self),
					CONNECT_ONE_SHOT
				)
				UIManager.blackout.blackout(true)
	)

	resume.pressed.connect(UIManager.button_pressed)
	settings.pressed.connect(UIManager.button_pressed)
	report.pressed.connect(UIManager.button_pressed)
	exit.pressed.connect(UIManager.button_pressed)

	resume.mouse_entered.connect(UIManager.button_hovered)
	settings.mouse_entered.connect(UIManager.button_hovered)
	report.mouse_entered.connect(UIManager.button_hovered)
	exit.mouse_entered.connect(UIManager.button_hovered)

	resume.mouse_exited.connect(UIManager.button_exited)
	settings.mouse_exited.connect(UIManager.button_exited)
	report.mouse_exited.connect(UIManager.button_exited)
	exit.mouse_exited.connect(UIManager.button_exited)


func _anim_is_finished(anim_name: String) -> void:
	if anim_name != "show":
		UIManager.ui_remove(self)
