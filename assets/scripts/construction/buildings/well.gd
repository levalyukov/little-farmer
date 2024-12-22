extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node = get_node("/root/"+main)
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

@onready var sprite:Sprite2D = $Sprite2D

var clicked:bool = false
var level:int = 1
var sprites:Dictionary = {
	"name": tr("Колодец"),
	"description": tr("Позволяет наполнить лейку"),
	1: {
		"default" = load("res://assets/resources/buildings/well/well.png"),
		"hover" = load("res://assets/resources/buildings/well/well_hover.png")
	}
}

func _input(event):
	if grid.mode == grid.modes.NOTHING:
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed():
			clicked = true

func _process(_delta):
	if clicked:
		if sprites != {}:
			if sprites.has(level):
				if sprites[level].has("hover"):
					if sprites[level]["hover"] is CompressedTexture2D:
						if sprite.texture == sprites[level]["hover"]:
							tools.water_can = tools.water_can_max
	clicked = false

func _on_area_2d_mouse_entered():
	if grid.mode == grid.modes.NOTHING:
		if sprites != {}:
			if sprites.has(level):
				if sprites[level].has("hover"):
					if sprites[level]["hover"] is CompressedTexture2D:
						sprite.texture = sprites[level]["hover"]
		if tip:
			if sprites.has("name")\
			&& sprites.has("description"):
				if sprites["name"] is String\
				&& sprites["description"] is String:
						tip.tooltip(sprites["name"] + "\n" + sprites["description"])

func _on_area_2d_mouse_exited():
	if grid.mode == grid.modes.NOTHING:
		if sprites != {}:
			if sprites.has(level):
				if sprites[level].has("default"):
					if sprites[level]["default"] is CompressedTexture2D:
						sprite.texture = sprites[level]["default"]
		if tip:
			tip.tooltip()
