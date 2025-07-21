extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")

@onready var _sprite:Sprite2D = $Sprite2D
@onready var _texture:Dictionary = {
	'spring': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_spring.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_spring_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_spring_delete.png")
	},
	'summer': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_summer.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_summer_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_summer_delete.png")
	},
	'autumn': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_autumn.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_autumn_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_autumn_delete.png")
	},
	'winter': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_winter.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_winter_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_winter_delete.png")
	},
}

var blueprint_id:int = 0
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var sprite_coords:Vector2i

const SPRING_COOLDOWN:int = 180
const SUMMER_COOLDOWN:int = 60
const AUTUMN_COOLDOWN:int = 120

func _ready():
	if _texture:
		if _texture.has(clock.get_season()): _sprite.texture = _texture[clock.get_season()]["default"]

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		buildings.remove_node(self, all_collisions)

func _on_area_2d_mouse_exited():
	if destroyMode: destroyMode = !true
	if _texture.has(clock.get_season()):
		if _texture[clock.get_season()]["default"] is CompressedTexture2D:
			_sprite.texture = _texture[clock.get_season()]["default"]

func _on_area_2d_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if buttonDestroy.destroyMode:
			destroyMode = true
			if _texture.has(clock.get_season()):
				if _texture[clock.get_season()].has("delete") && _texture[clock.get_season()]["delete"] is CompressedTexture2D:
					_sprite.texture = _texture[clock.get_season()]["delete"]
		else:
			_sprite.texture = _texture[clock.get_season()]["default"]
	
func get_data() -> Dictionary:
	return {
		"position": tilemap.local_to_map(self.position),
		"id": blueprint_id,
		'all_collisions': all_collisions
	}