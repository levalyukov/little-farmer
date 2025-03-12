extends Control

@onready var container:MarginContainer = $Container
@onready var label:Label = $Container/MarginContainer/Label

var tip:bool

func _process(_delta):
	if tip:
		position = get_global_mouse_position()

func tooltip(text:String = "") -> void:
	if text != "":
		tip = true
		label.text = text
		if !visible:
			visible = true
	else:
		tip = false
		if visible:
			visible = false
