extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud/")
@onready var destroy_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var destroy_main_menu:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/DestroyMenuMargin/DestroyMenu")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/destroy_buildings.png")
@onready var icon:TextureRect = $Main/Margin/Icon

func _ready() -> void:
	icon.texture = sprite

func _on_button_pressed() -> void:
	if !pause.paused\
	&& hud.visible\
	&& !destroy_menu.destroyMode:
		grid.mode = grid.modes.NOTHING
		destroy_menu.destroyMode = true
		hud.hud_all_hide()
		destroy_main_menu.close()
