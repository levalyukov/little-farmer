extends Control

@onready var animalIcon:TextureRect = $MarginContainer/MarginContainer/HBoxContainer/MarginContainer/TextureRect;
@onready var animalName:Label = $MarginContainer/MarginContainer/HBoxContainer/MarginContainer2/Label;
@onready var buttonSource:Button = $MarginContainer/Button

func change_icon(_icon:CompressedTexture2D):
	if !animalIcon: return;
	animalIcon.texture = _icon;

func change_name(_name:String):
	if !animalName: return;
	animalName.text = _name;
