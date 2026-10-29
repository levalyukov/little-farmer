extends Node2D

@onready var radio_area: Area2D = $Radio/Area2D
@onready var radio_sprite: Sprite2D = $Radio/Sprite2D
@onready var radio_audio: AudioStreamPlayer2D = $Radio/AudioStreamPlayer2D

@onready var mailbox_area: Area2D = $Mailbox/Area2D
@onready var mailbox_sprite: Sprite2D = $Mailbox/Sprite2D


func _ready() -> void:
	_init_radio()
	_init_mailbox()


func _init_radio() -> void:
	if !SoundManager.radio.is_empty():
		return

	if radio_area != null:
		radio_area.input_pickable = true
		radio_area.input_event.connect(
			func(_viewport: Node, event: InputEvent, _index: int) -> void:
				if (
					event is InputEventMouseButton
					&& event.pressed
					&& !UIManager.blur.state
					&& event.button_index == MOUSE_BUTTON_LEFT
				):
					radio_audio.set_stream_paused(true if !radio_audio.stream_paused else false)
		)

		radio_area.mouse_entered.connect(
			func() -> void:
				if radio_sprite.material:
					radio_sprite.material.set_shader_parameter("highligth", true)
					UIManager.cursor.set_cursor(UIManager.cursor.States.ACTIVE)
		)

		radio_area.mouse_exited.connect(
			func() -> void:
				if radio_sprite.material:
					radio_sprite.material.set_shader_parameter("highligth", false)
					UIManager.cursor.set_cursor(UIManager.cursor.States.DEFAULT)
		)


func _init_mailbox() -> void:
	if mailbox_area != null:
		mailbox_area.input_pickable = true
		mailbox_area.input_event.connect(
			func(_viewport: Node, event: InputEvent, _index: int) -> void:
				if (
					event is InputEventMouseButton
					&& event.pressed
					&& !UIManager.blur.state
					&& event.button_index == MOUSE_BUTTON_LEFT
				):
					if owner.ui && (owner.ui.has_method("open_window") && owner.ui.has_method("close_window")):
						if !owner.ui.windows.has(MMWindows.MenuWindows.NEWS):
							owner.ui.open_window(MMWindows.MenuWindows.NEWS)
						else:
							owner.ui.close_window(MMWindows.MenuWindows.NEWS)
		)

		mailbox_area.mouse_entered.connect(
			func() -> void:
				if mailbox_sprite.material:
					mailbox_sprite.material.set_shader_parameter("highligth", true)
					UIManager.cursor.set_cursor(UIManager.cursor.States.ACTIVE)
		)

		mailbox_area.mouse_exited.connect(
			func() -> void:
				if mailbox_sprite.material:
					mailbox_sprite.material.set_shader_parameter("highligth", false)
					UIManager.cursor.set_cursor(UIManager.cursor.States.DEFAULT)
		)
