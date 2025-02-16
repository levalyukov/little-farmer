extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var menu:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/Canvas/Options/Blur")
@onready var scroll:ScrollContainer = $Panel/Main/ScrollContainer
@onready var anim:AnimationPlayer = $AnimationPlayer
var status:bool = false

func _ready():
	_window()

func open() -> void:
	anim.play("open")
	blur.blur(true)
	status = true
	menu.clicked = true
	menu.change_button_state(true)
	scroll.scroll_vertical = 0

func close() -> void:
	anim.play("close")
	blur.blur(false)
	status = false
	menu.clicked = false
	menu.change_button_state(false)

func _window() -> void:
	visible = status

func _on_button_pressed():
	if visible:
		close()
