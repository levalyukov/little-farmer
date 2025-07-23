extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")

@onready var _sprite:Sprite2D = $Sprite2D

var object:Dictionary = {
	"seasons": {
		'spring': {
			'default': preload("res://assets/resources/buildings/fence/fence_spring.png"),
			'delete': preload("res://assets/resources/buildings/fence/fence_spring_delete.png")
		},
		'summer': {
			'default': preload("res://assets/resources/buildings/fence/fence_summer.png"),
			'delete': preload("res://assets/resources/buildings/fence/fence_summer_delete.png")
		},
		'autumn': {
			'default': preload("res://assets/resources/buildings/fence/fence_autumn.png"),
			'delete': preload("res://assets/resources/buildings/fence/fence_autumn_delete.png")
		},
		'winter': {
			'default': preload("res://assets/resources/buildings/fence/fence_winter.png"),
			'delete': preload("res://assets/resources/buildings/fence/fence_winter_delete.png")
		},
	}
}

var blueprint_id:int = 0
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var sprite_coords:Vector2i

func _ready():
	if object:
		if object["seasons"].has(clock.get_season()): _sprite.texture = object["seasons"][clock.get_season()]["default"]

#	func set_sprite(_x:int, _y:int) -> void:
#		_sprite.region_rect.position = Vector2i(_x, _y)

#	func moving_sprite() -> void:
#		if abs(sprite_coords.x + 16) != object["seasons"][clock.get_season()]["default"].get_size().x:
#			sprite_coords.x += 16
#		else:
#			sprite_coords.x = 0

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		buildings.remove_node(self, all_collisions)

func update() -> void:
	if clock:
		var new_season = clock.get_season()
		if object["seasons"].has(new_season) && object["seasons"][new_season].has("default"):
			_sprite.texture = object["seasons"][new_season]["default"]

func _on_area_2d_mouse_exited():
	if destroyMode: destroyMode = !true
	if object["seasons"].has(clock.get_season()):
		if object["seasons"][clock.get_season()]["default"] is CompressedTexture2D:
			_sprite.texture = object["seasons"][clock.get_season()]["default"]

func _on_area_2d_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if buttonDestroy.destroyMode:
			destroyMode = true
			if object["seasons"].has(clock.get_season()):
				if object["seasons"][clock.get_season()].has("delete") && object["seasons"][clock.get_season()]["delete"] is CompressedTexture2D:
					_sprite.texture = object["seasons"][clock.get_season()]["delete"]
		else:
			_sprite.texture = object["seasons"][clock.get_season()]["default"]
	
func get_data() -> Dictionary:
	return {
		"position": tilemap.local_to_map(self.position),
		"id": blueprint_id,
		'all_collisions': all_collisions
	}