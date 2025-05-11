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
@onready var compostMenu:Control = get_node("/root/"+main+"/UI/Interactive/ComposterMenu")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D
@onready var timer:Timer = $Timer

var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var menu:bool = false
var level:int = 1
var blueprint_id:int = 0
var menuAccess:bool = false
var composting:bool = false
var composting_value:float = 0.0
var compost_items:Dictionary = {}
var highQuality:bool = false
var total_items:int = 0

enum objectState {idle, inProcess, done}
var object:Dictionary = {
	1: {
		"shadow" = load("res://assets/resources/buildings/composter/shadow.png"),
		"state" = {
			"idle" = {
				"default" = load('res://assets/resources/buildings/composter/idle_0.png'),
				"hovered" = load('res://assets/resources/buildings/composter/idle_1.png'),
				"delete" = load('res://assets/resources/buildings/composter/idle_2.png')
			},
			"work" = {
				"default" = load('res://assets/resources/buildings/composter/active_0.png'),
				"hovered" = load('res://assets/resources/buildings/composter/active_1.png'),
				"delete" = load('res://assets/resources/buildings/composter/active_2.png')
			}
		}
	},
}

func _ready():
	update()
	update_texture()

func update_texture() -> void:
	if composting:
		if object[level]["state"].has("work"):
			if object[level]["state"]['work'].has("default"):
				if object[level]["state"]['work']["default"] is CompressedTexture2D:
					sprite.texture = object[level]["state"]['work']["default"]
	else:
		if object[level]["state"].has("idle"):
			if object[level]["state"]['idle'].has("default"):
				if object[level]["state"]['idle']["default"] is CompressedTexture2D:
					sprite.texture = object[level]["state"]['idle']["default"]

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& !buttonDestroy.destroyMode\
	&& grid.mode == grid.modes.NOTHING\
	&& menuAccess:
		compostMenu.open(self)
		menuAccess = false
		if object.has(level):
			if object[level].has("state"):
				if composting:
					if object[level]["state"].has("work"):
						if object[level]["state"]['work'].has("default"):
							if object[level]["state"]['work']["default"] is CompressedTexture2D:
								sprite.texture = object[level]["state"]['work']["default"]
				else:
					if object[level]["state"].has("idle"):
						if object[level]["state"]['idle'].has("default"):
							if object[level]["state"]['idle']["default"] is CompressedTexture2D:
								sprite.texture = object[level]["state"]['idle']["default"]
		if tip:
			tip.tooltip()
	else:
		if event is InputEventMouseButton\
		&& event.button_index == MOUSE_BUTTON_LEFT\
		&& event.is_pressed()\
		&& !blur.state\
		&& destroyMode\
		&& buttonDestroy.destroyMode\
		&& !composting:
			buildings.remove_node(self, all_collisions)

func update():
	if clock:
		if object.has(level):
			if composting:
				if object[level]["state"].has("work"):
					if object[level]["state"]['work'].has("default"):
						if object[level]["state"]['work']["default"] is CompressedTexture2D:
							sprite.texture = object[level]["state"]['work']["default"]
			else:
				if object[level].has("state"):
					if object[level]["state"].has("idle"):
						if object[level]["state"]["idle"].has("idle_0"):
							if object[level]["state"]["idle"]["idle_0"] is CompressedTexture2D:
								sprite.texture = object[level]["idle"]["idle_0"]
								self.set_position(tilemap.map_to_local(Vector2i(18,2)))

func get_data() -> Dictionary:
	if object.has(level):
		return {
			"level": level,
			"value": composting_value,
			"position": tilemap.local_to_map(position),
			"id": blueprint_id,
			"state": composting,
			"total_items": total_items,
			'all_collisions': all_collisions
			}
	return {}

func _on_area_2d_mouse_entered() -> void:
	if !buttonDestroy.destroyMode:
		menuAccess = true
		if !blur.state:
			var distance = round(global_position.distance_to(player.global_position))
			if grid.mode == grid.modes.NOTHING && distance < building.max_distance:
				if cursor: cursor.set_cursor(cursor.states.ACTIVE)
				if object.has(level):
					if object[level].has("state"):
						if composting:
							if object[level]["state"].has("work"):
								if object[level]["state"]['work'].has("hovered"):
									if object[level]["state"]['work']["hovered"] is CompressedTexture2D:
										sprite.texture = object[level]["state"]['work']["hovered"]
						else:
							if object[level]["state"].has("idle"):
								if object[level]["state"]['idle'].has("hovered"):
									if object[level]["state"]['idle']["hovered"] is CompressedTexture2D:
										sprite.texture = object[level]["state"]['idle']["hovered"]
				if tip:
					tip.tooltip(tr('object.composter.caption') + "\n" +tr('object.composter.description'))
	if buttonDestroy.destroyMode:
		if !blur.state:
			destroyMode = true
			var distance = round(global_position.distance_to(player.global_position))
			if grid.mode == grid.modes.NOTHING and distance < building.max_distance:
				if object.has(level):
					if object[level].has("state"):
						if !composting:
							if object[level]["state"].has("idle"):
								if object[level]["state"]['idle'].has("delete"):
									if object[level]["state"]['idle']["delete"] is CompressedTexture2D:
										sprite.texture = object[level]["state"]['idle']["delete"]
								
func _on_area_2d_mouse_exited() -> void:
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	menuAccess = false
	destroyMode = !true
	if object.has(level):
		if object[level].has("state"):
			if composting:
				if object[level]["state"].has("work"):
					if object[level]["state"]['work'].has("default"):
						if object[level]["state"]['work']["default"] is CompressedTexture2D:
							sprite.texture = object[level]["state"]['work']["default"]
			else:
				if object[level]["state"].has("idle"):
					if object[level]["state"]['idle'].has("default"):
						if object[level]["state"]['idle']["default"] is CompressedTexture2D:
							sprite.texture = object[level]["state"]['idle']["default"]
	if tip:
		tip.tooltip()

func start_compost(items_compost_value:int) -> void:
	timer.start()
	timer.wait_time = 2.5
	total_items = items_compost_value
	update()

func stop_compost() -> void:
	timer.stop()
	update()

func _on_timer_timeout():
	if composting_value >= 100:
		timer.stop()
		update()
	else:
		composting_value += randf_range(0.01, 2.5)