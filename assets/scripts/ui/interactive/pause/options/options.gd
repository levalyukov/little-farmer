extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var change_language = get_node("/root/"+main+"/User Interface/Windows/Options/Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language")
@onready var button_container:VBoxContainer = $Panel/Main/HBoxContainer/VBoxContainer/Buttons/VBoxContainer
@onready var pages_container:VBoxContainer = $Panel/Main/HBoxContainer/Pages/VBoxContainer
@onready var language_button:Control = $Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Language/MarginContainer/Label
@onready var exit_button:Control = $Panel/Main/HBoxContainer/VBoxContainer/VBoxContainer/Exit/MarginContainer/Label
@onready var anim:AnimationPlayer = $AnimationPlayer

var opened:bool = false

func _ready():
	window()

func open() -> void:
	anim.play("open")
	opened = true
	if main == "MainMenu":
		var options = get_node("/root/"+main)
		if options:
			options.clicked = true

func close() -> void:
	anim.play("close")
	opened = false
	if main == "MainMenu":
		var options = get_node("/root/"+main)
		if options:
			options.clicked = false
	
func window():
	visible = opened
	
