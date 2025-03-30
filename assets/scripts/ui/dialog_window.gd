extends Control

@onready var mainLabel = $MarginContainer/Panel/VBoxContainer/MainContent/Panel/MainText/VBoxContainer/MarginContainer2/Label
@onready var buttonContainer = $MarginContainer/Panel/VBoxContainer/MarginContainer2/Answers/MarginContainer/HBoxContainer
@onready var animation:AnimationPlayer = $AnimationPlayer

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")

var opened:bool = false
var visibled:bool = false
var npc_id:int

func _ready():
	_check_window_state()
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		dialogWindowClose()

func dialogWindow(npcCaption:String, mainContent:Array, buttonsCaption:Dictionary, buttonFunc:Dictionary, npc_art:int = 0) -> void:
	if !opened:
		opened = true
		visibled = true
		animation.play('open')
		mainLabel.setDialogText(npcCaption, mainContent, buttonsCaption, buttonFunc)
		npc_id = npc_art
		if blur:
			blur.blur(true)

func dialogWindowClose() -> void:
	if opened:
		animation.play('close')
		opened = !true
		visibled = !true
		mainLabel.resetDialogText()

func _check_window_state() -> void:
	visible = visibled
	if pause:
		pause.other_menu = opened
