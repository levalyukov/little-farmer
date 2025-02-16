extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/tools/watering_can.png")
@onready var icon:TextureRect = $Main/Margin/Icon

func _ready() -> void:
	icon.texture = sprite

func _on_button_pressed() -> void:
	if !pause.paused:
		if has_node("/root/"+main+"/ConstructionManager")\
		&& has_node("/root/"+main+"/ConstructionManager/Grid"):
			if !blur.state:
				grid.grid_dimensions = tools.features["watering_can"][tools.watering_can]["grid_dimensions"]
				grid.mode = grid.modes.WATERING
				grid.visible = true
				grid.generate_grid()
