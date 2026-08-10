extends Control

# =============================================================================================
# (credits.gd)
# =============================================================================================
# Окно титров игры в главном меню
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Открытие окна с авторами и инструментами игры
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - open()
# - close()
#
# ЗАВИСИМОСТИ:
# - Blur - для размытия фона
# - Cursor - для изменений состояний
#
# =============================================================================================

@onready var anim: AnimationPlayer = $Animation
@onready var title: Label = $MainContainer/VBox/HeaderContainer/Title
@onready var general: RichTextLabel = $MainContainer/VBox/ContentContainer/Content
@onready var button: Button = $MainContainer/VBox/ButtonsContainer/HBox/ConfirmButtonMargin/Confirm

var title_text: String = tr("menu.credits_title")
var general_text: String = tr("menu.credits_content")


func _ready() -> void:
	title.text = title_text
	general.text = general_text

	button.pressed.connect(close)
	button.mouse_entered.connect(_button_hovered)
	button.mouse_exited.connect(_button_exited)
	anim.animation_finished.connect(_anim_is_finished)

	open()


func open() -> void:
	UIManager.blur.blur(true)
	anim.play("show")
	self.visible = true


func close() -> void:
	UIManager.blur.blur(false)
	anim.play("hide")
	SoundManager.play_sound("ui/click")
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)


func _button_hovered() -> void:
	SoundManager.play_sound("ui/hover")
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _button_exited() -> void:
	SoundManager.play_sound("ui/hover")
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)


func _anim_is_finished(anim_name: String) -> void:
	if anim_name != "show":
		UIManager.ui_remove(self)
