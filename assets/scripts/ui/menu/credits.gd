extends Control

@onready var anim: AnimationPlayer = $Animation
@onready var title: Label = $MainContainer/VBox/HeaderContainer/Title
@onready var general: RichTextLabel = $MainContainer/VBox/ContentContainer/Content
@onready var button: Button = $MainContainer/VBox/ButtonsContainer/HBox/ConfirmButtonMargin/Confirm


func _ready() -> void:
	title.text = tr("menu.credits_title")
	general.text = tr("menu.credits_content")

	button.pressed.connect(close)
	button.mouse_entered.connect(_button_hovered)
	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				UIManager.remove_ui(self)
	)

	UIManager.blur.blur(true)
	anim.play("show")
	self.visible = true


func close() -> void:
	UIManager.blur.blur(false)
	anim.play("hide")
	SoundManager.play_sound("ui/click")


func _button_hovered() -> void:
	SoundManager.play_sound("ui/hover")
