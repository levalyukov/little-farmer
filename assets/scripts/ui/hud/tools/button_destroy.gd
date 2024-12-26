extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/eraser.png")
@onready var icon:TextureRect = $Main/Margin/Icon

@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")

func _ready() -> void:
	icon.texture = sprite

func _on_button_pressed() -> void:
	if !pause.paused:
		if has_node("/root/"+main+"/ConstructionManager")\
		&& has_node("/root/"+main+"/ConstructionManager/Grid"):
			if !blur.state:
				if !destroy_menu.opened:
					destroy_menu.open()
				else:
					destroy_menu.close()

