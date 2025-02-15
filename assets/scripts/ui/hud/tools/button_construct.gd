extends Control

@onready var main:String = GameData.main
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var craft:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/hammer.png")
@onready var icon:TextureRect = $Main/Margin/Icon

func _ready() -> void:
	icon.texture = sprite

func _on_button_pressed() -> void:
	if !pause.paused:
		if !blur.state:
			craft.open()
