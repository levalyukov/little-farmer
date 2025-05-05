extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var mail:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var container:MarginContainer = $MainContainer
@onready var header:Label = $MainContainer/VBox/HeaderContainer/Header
@onready var content:Label = $MainContainer/VBox/ContentContainer/Content
@onready var button_confirm_container:MarginContainer = $MainContainer/VBox/ButtonsContainer/HBox/ConfirmButtonMargin
@onready var button_cancel_container:MarginContainer = $MainContainer/VBox/ButtonsContainer/HBox/CancelButtonMargin
@onready var button_confirm:Button = $MainContainer/VBox/ButtonsContainer/HBox/ConfirmButtonMargin/Confirm
@onready var button_cancel:Button = $MainContainer/VBox/ButtonsContainer/HBox/CancelButtonMargin/Cancel
@onready var anim:AnimationPlayer = $Animation

var state:bool = false
func _ready():
	_check_window()

func modal_create(header_value:String, content_value:String, button_string:String = tr('Продолжить')) -> void:
	if header_value != ""\
	&& content_value != "":
		header.text = header_value
		content.text = content_value
		button_confirm_container.visible = true
		button_confirm.text = tr(button_string)
		anim.play("create")
		change_all_z_index(-1)
		state = true
		if main == "MainMenu":
			var menu = get_node("/root/"+main+"")
			var blur = get_node("/root/"+main+"/Blur")
			blur.blur(true)
			menu.clicked = true

func modal_remove() -> void:
	anim.play("remove")
	change_all_z_index(0)
	state = false
	if main == "MainMenu":
		var menu = get_node("/root/"+main+"")
		var blur = get_node("/root/"+main+"/Blur")
		blur.blur(false)
		menu.clicked = !true
		GameLoader.modal = true

func change_all_z_index(value:int) -> void:
	if has_node("/root/"+main+"/UI/Interactive/Mailbox"):
		var mailbox = get_node("/root/"+main+"/UI/Interactive/Mailbox")
		mailbox.z_index = value

func _check_window():
	visible = state

func _on_confirm_pressed() -> void:
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()
	modal_remove()
	cursor_update(false)

func _on_confirm_mouse_entered():
	if visible:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()
		cursor_update(true)

func _on_confirm_mouse_exited():
	if visible:
		cursor_update(false)

func cursor_update(cursor_state:bool) -> void:
	match cursor_state:
		true:
			match main:
				'MainMenu':
					var cursor = get_node('/root/'+main+'/Cursor')
					if cursor:cursor.set_cursor(cursor.states.ACTIVE)
				'Farm':
					var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
					if cursor:cursor.set_cursor(cursor.states.ACTIVE)
		false:
			match main:
				'MainMenu':
					var cursor = get_node('/root/'+main+'/Cursor')
					if cursor:cursor.set_cursor(cursor.states.DEFAULT)
				'Farm':
					var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
					if cursor:cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(node) -> void:
	node.queue_free()