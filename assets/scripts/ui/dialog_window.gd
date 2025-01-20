extends Control

@onready var mainLabel = $MarginContainer/Panel/VBoxContainer/MainText/VBoxContainer/MarginContainer2/Label
@onready var buttonContainer = $MarginContainer/Panel/VBoxContainer/Answers/MarginContainer/HBoxContainer
@onready var animation:AnimationPlayer = $AnimationPlayer
var opened:bool = false
var visibled:bool = false

func _ready():
	dialogWindow(
		"Разбитая могила",
		[
			'Перед вами заброшенная могила, разрушенная временем.\n\nНа потрескавшейся могильной плите едва угадываются несколько букв имени покоящейся здесь женщины:\n\n - Тя..на Анна (200x — 20xx)', 
			'Приблизившись, вы замечаете под плитой небольшой клочок бумаги. Похоже, это чья-то записка.',
		], 
		{
			0:['* Подойти поближе *','* Отойти *'],
			1:['* Поднять записку *'],
		},
		{
			0:[1,0],
			1:[2],
		}
		)

func dialogWindow(npcCaption:String, mainContent:Array[String], buttonsCaption:Dictionary, buttonFunc:Dictionary) -> void:
	if !opened:
		opened = true
		visibled = true
		animation.play('open')
		mainLabel.setDialogText(npcCaption, mainContent, buttonsCaption, buttonFunc)

func dialogWindowClose() -> void:
	if opened:
		animation.play('close')
		visibled = !true

func _check_window_state() -> void:
	visible = visibled
