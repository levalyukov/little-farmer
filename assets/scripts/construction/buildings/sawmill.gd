extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sawmillMenu:Control = get_node("/root/"+main+"/UI/Interactive/SawmillMenu")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D

var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var blueprint_id:int = 0
var menuAccess:bool = false
var object:Dictionary = {
	'caption': tr('Пилостол'),
	'description': tr('Превращает бревна в доски'),
	'default': load('res://assets/resources/buildings/sawmill/obj_0.png'),
	'hovered': load('res://assets/resources/buildings/sawmill/obj_1.png'),
	'delete': load('res://assets/resources/buildings/sawmill/obj_2.png'),
}

var logID
var logAmount:int = 0

func _ready():
	update()

func update() -> void:
	if object.has('default'):
		if object['default'] is CompressedTexture2D:
			sprite.texture = object['default']

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& !buttonDestroy.destroyMode\
	&& grid.mode == grid.modes.NOTHING\
	&& menuAccess:
		sawmillMenu.open(self)

func _on_area_2d_mouse_entered():
	if !pause.paused:
		if !buttonDestroy.destroyMode\
		&& grid.mode == grid.modes.NOTHING:
			if !menuAccess:
				menuAccess = true
			if !blur.state:
				if object.has('hovered'):
					if object['hovered'] is CompressedTexture2D:
						sprite.texture = object['hovered']
			if !tip.visible:
				tip.tooltip(
					object['caption'] + '\n' + object['description']
				)
		else:
			if destroyMode:
				destroyMode = true
			if !blur.state:
				if object.has('delete'):
					if object['delete'] is CompressedTexture2D:
						sprite.texture = object['delete']

func _on_area_2d_mouse_exited():
	if menuAccess:
		menuAccess = false
	if destroyMode:
		destroyMode = false
	if object.has('default'):
		if object['default'] is CompressedTexture2D:
			sprite.texture = object['default']
	if tip:
		if tip.visible:
			tip.tooltip()

func get_data() -> Dictionary:
	return {
		"position": tilemap.local_to_map(position),
		"id": blueprint_id,
		'all_collisions': all_collisions
		}
