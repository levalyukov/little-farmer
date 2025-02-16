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

func modal_create(header_value:String, content_value:String, button_confirm_value:String = "", button_cancel_value:String = "") -> void:
	if header_value != ""\
	&& content_value != "":
		header.text = header_value
		content.text = content_value
		if button_confirm_value == "":
			button_confirm_container.visible = false
		else:
			button_confirm.text = button_confirm_value

		if button_cancel_value == "":
			button_cancel_container.visible = false
		else:
			button_cancel.text = button_cancel_value

		if (button_confirm_value == "") && (button_cancel_value == ""):
			button_confirm_value = tr("Продолжить")
			button_confirm_container.visible = true
			button_confirm.text = button_confirm_value

		anim.play("create")
		change_all_z_index(-1)
		state = true

func modal_remove() -> void:
	anim.play("remove")
	change_all_z_index(0)
	state = false

func change_all_z_index(value:int) -> void:
	if has_node("/root/"+main+"/UI/Interactive/Mailbox"):
		var mailbox = get_node("/root/"+main+"/UI/Interactive/Mailbox")
		mailbox.z_index = value

func _check_window():
	visible = state

# Modal window response:
func _on_confirm_pressed() -> bool:
	modal_remove()
	return true

func _on_cancel_pressed() -> bool:
	modal_remove()
	return false
