extends Control

@onready var mainLabel = $MarginContainer/Panel/VBoxContainer/MainContent/Panel/MainText/VBoxContainer/MarginContainer2/Label
@onready var buttonContainer = $MarginContainer/Panel/VBoxContainer/MarginContainer2/Answers/MarginContainer/HBoxContainer
@onready var animation:AnimationPlayer = $AnimationPlayer

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")

var opened:bool = true
var visibled:bool = false

func _ready():
	dialogWindowClose()

func _input(event):
	if Input.is_action_just_pressed('space'):
		#dialogWindow(
		#	"Разбитая могила",
		#	[
		#		'Перед вами заброшенная могила, разрушенная временем.\n\nНа потрескавшейся могильной плите едва угадываются несколько букв имени покоящейся здесь женщины:\n\n - Тя..на Анна (200x — 20xx)', 
		#		'Приблизившись, вы замечаете под плитой небольшой клочок бумаги. Похоже, это чья-то записка.',
		#	], 
		#	{
		#		0:['* Подойти поближе *','* Отойти *'],
		#		1:['* Поднять записку *'],
		#	},
		#	{
		#		0:[1,0],
		#		1:[0],
		#	}
		#	)
		dialogWindow(
			'Добрыня',
			[
				'Добрый день, юный садовод! Меня зовут Добрыня — местный торговец и садовод по совместительству.\n\nУ меня ты можешь приобрести семена на сезон, а также полезные вещи для сада.', 
			], 
			{
				0:['Интересно узнать твой ассортимент [Торговля]','Всего доброго! [Закрыть]'],
			},
			{
				0:[2,0],
			}
			)

	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		dialogWindowClose()

func dialogWindow(npcCaption:String, mainContent:Array[String], buttonsCaption:Dictionary, buttonFunc:Dictionary) -> void:
	if !opened:
		opened = true
		visibled = true
		animation.play('open')
		mainLabel.setDialogText(npcCaption, mainContent, buttonsCaption, buttonFunc)
		if blur:
			blur.blur(true)

func dialogWindowClose() -> void:
	if opened:
		animation.play('close')
		opened = !true
		visibled = !true

func _check_window_state() -> void:
	visible = visibled
	if pause:
		pause.other_menu = opened
