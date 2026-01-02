extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var animations:AnimationPlayer = $AnimationPlayer
@onready var indicator:Node2D = $Indicator
@onready var sprite:Sprite2D = $Sprite2D

@onready var animalMenu:Control = get_node("/root/"+main+"/UI/Interactive/AnimallStallMenu")
@onready var animalManager:Node2D = get_node("/root/"+main+"/AnimalManager")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

var hovered:bool = false ; # Состояние мышки
var animalResources:bool = false # я хз как назвать эту переменную, но это флаг для того чтобы можно собрать животные ресурсы: яйца, молоко и т.д.
var opened:bool = false;
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var level:int = 1
var blueprint_id:int = 0
var object:Dictionary = {
	1: {
		"shadow" = load("res://assets/resources/buildings/stall/level_1/shadow.png"),
		"seasons" = {
			"spring" = {
				"default" = load("res://assets/resources/buildings/stall/level_1/spring/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/stall/level_1/spring/object_1.png"),
				"delete" = load("res://assets/resources/buildings/stall/level_1/spring/object_2.png")
			},
			"summer" = {
				"default" = load("res://assets/resources/buildings/stall/level_1/summer/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/stall/level_1/summer/object_1.png"),
				"delete" = load("res://assets/resources/buildings/stall/level_1/summer/object_2.png")
			},
			"autumn" = {
				"default" = load("res://assets/resources/buildings/stall/level_1/autumn/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/stall/level_1/autumn/object_1.png"),
				"delete" = load("res://assets/resources/buildings/stall/level_1/autumn/object_2.png")
			},
			"winter" = {
				"default" = load("res://assets/resources/buildings/stall/level_1/winter/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/stall/level_1/winter/object_1.png"),
				"delete" = load("res://assets/resources/buildings/stall/level_1/winter/object_2.png")
			},
		}
	},
}

func get_animal_resource() -> void:
	if !inventory: 	return;
	if !animations: return;
	if !indicator: 	return;

	if !animalResources: 
		animalResources = true;
		indicator.visible = true;
		animations.play("bubble");

func _ready() -> void: 
	if indicator.visible: indicator.visible = false; 
	update(); 

func update() -> void:
	if object.has(level):
		if object[level].has("seasons"):
			var season = clock.get_season()
			if object[level]["seasons"].has(season):
				if object[level]["seasons"][season].has("default"):
					sprite.texture = object[level]["seasons"][season]["default"]

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING && distance < buildings.max_distance:
			if object.has(level):
				if object.has(level):
					if object[level].has("seasons"):
						var season = clock.get_season()
						if object[level]["seasons"].has(season):
							if object[level]["seasons"][season].has("hovered"):
								sprite.texture = object[level]["seasons"][season]["hovered"]
			tip.tooltip(
					str(tr("object.animal_stall.caption")) + "\n" +
					str(tr("object.animal_stall.description")) + "\n"
				)
	else:
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("default"):
						sprite.texture = object[level]["seasons"][season]["default"]
			else: data.debug("There is no key at index " + str(level) + ".", "error")
		else: data.debug("Index " + str(level) + " is not in the dictionary.", "error")
		if tip: tip.tooltip("")

func _input(event) -> void:
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& grid.mode == grid.modes.NOTHING\
	&& !blur.state\
	&& hovered:
		if inventory && animalManager:
			if self in animalManager.get_spawns():
				if animalManager.get_animals_by_spawn(self).size() == 0: 
					animalResources = false;
					if indicator.visible: indicator.visible = false;
					if animations: animations.stop();
					return;
				
				var value:int = 0;
				var _animals = animalManager.get_animals_by_spawn(self);
				for i in _animals: 
					_animals[i]["time"] = 14;
					_animals[i]["resource"] = false;
					value+=1;
					
				inventory.add_item(74,value);
				animalResources = false;
				if indicator.visible: indicator.visible = false;
				if animations: animations.stop();

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		if animalManager: animalManager.remove_spawn(self);
		if buildings: buildings.remove_node(self, all_collisions)

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& !destroyMode\
	&& opened\
	&& !buttonDestroy.destroyMode:
		if animalMenu: animalMenu.open(self);
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func get_data() -> Dictionary:
	if object.has(level):
		return {
			"id": blueprint_id,
			"position": tilemap.local_to_map(position),
			"level": level,
			'all_collisions': all_collisions
		}
	return {}
	
func _on_area_2d_mouse_entered() -> void:
	if cursor: cursor.set_cursor(cursor.states.ACTIVE)

	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& !buttonDestroy.destroyMode\
	&& animalResources\
	&& !opened:
		_change_sprite(true)
		hovered = true;

	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& !animalResources\
	&& !buttonDestroy.destroyMode:
		_change_sprite(true)
		opened = true;

	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& buttonDestroy.destroyMode:
		destroyMode = true
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("delete"):
						if object[level]["seasons"][season]["delete"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["delete"]

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
	if hovered: hovered = false;
	if opened: opened = false;
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if destroyMode: destroyMode = !true
