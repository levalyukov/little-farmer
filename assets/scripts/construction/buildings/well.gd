extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

@onready var sprite:Sprite2D = $Sprite2D

var clicked:bool = false
var level:int = 1
var blueprint_id:int = 0
var object:Dictionary = {
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
		if object != {}:
			if object.has(level):
				if object[level].has("hover"):
					if object[level]["hover"] is CompressedTexture2D:
						if sprite.texture == object[level]["hover"]:
							tools.water_can = tools.water_can_max
	clicked = false

func _on_area_2d_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if object != {}:
			if object.has(level):
				if object[level].has("hover"):
					if object[level]["hover"] is CompressedTexture2D:
						sprite.texture = object[level]["hover"]
		if tip:
			if object.has("name")\
			&& object.has("description"):
				if object["name"] is String\
				&& object["description"] is String:
						tip.tooltip(object["name"] + "\n" + object["description"])

func _on_area_2d_mouse_exited():
	if grid.mode == grid.modes.NOTHING:
		if object != {}:
			if object.has(level):
				if object[level].has("default"):
					if object[level]["default"] is CompressedTexture2D:
						sprite.texture = object[level]["default"]
		if tip:
			tip.tooltip()

func get_data() -> Dictionary:
	if object.has(level):
		return {
			"id": blueprint_id,
			"position": tilemap.local_to_map(position),
			"level": level
		}
	return {}