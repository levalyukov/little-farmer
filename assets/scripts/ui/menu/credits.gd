extends Control

@onready var anim: AnimationPlayer = $Animation
@onready var title: Label = $VBox/Header/Label
@onready var general: RichTextLabel = $VBox/Content/RichLabel
@onready var button: Button = $VBox/Buttons/HBox/ConfirmButtonMargin/Confirm

var title_text: String = tr("menu.credits_title")
var general_text: String = tr("menu.credits_content")
var button_text: String = tr("menu.credits_button")


func _ready() -> void:
	title.text = title_text
	general.text = general_text
	button.text = button_text

	button.pressed.connect(
		func() -> void:
			anim.play("hide")
			SoundManager.play_sound("ui/click")
	)

	button.mouse_entered.connect(UIManager.button_hovered)
	button.mouse_exited.connect(UIManager.button_exited)

	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				var ui: Control = get_tree().current_scene.ui
				if ui && ui.has_method("close_window"):
					ui.close_window(MMWindows.MenuWindows.CREDITS)
	)

	anim.play("show")
	self.visible = true
