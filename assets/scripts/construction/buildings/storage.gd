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
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D

var menu:bool = false
var level:int = 1
var object:Dictionary = {
	1: {
		"slots" = 100,
		"seasons" = {
			"spring" = {
				"default" = preload("res://assets/resources/buildings/storage/spring/level_1/object_0.png"),
				"hovered" = preload("res://assets/resources/buildings/storage/spring/level_1/object_1.png"),
				"shadow" = preload("res://assets/resources/buildings/storage/spring/level_1/shadow.png"),
			},
			"summer" = {
				"default" = preload("res://assets/resources/buildings/storage/summer/level_1/object_0.png"),
				"hovered" = preload("res://assets/resources/buildings/storage/summer/level_1/object_1.png"),
				"shadow" = preload("res://assets/resources/buildings/storage/summer/level_1/shadow.png"),
			},
			"autumn" = {
				"default" = preload("res://assets/resources/buildings/storage/autumn/level_1/object_0.png"),
				"hovered" = preload("res://assets/resources/buildings/storage/autumn/level_1/object_1.png"),
				"shadow" = preload("res://assets/resources/buildings/storage/autumn/level_1/shadow.png"),
			},
			"winter" = {
				"default" = preload("res://assets/resources/buildings/storage/winter/level_1/object_0.png"),
				"hovered" = preload("res://assets/resources/buildings/storage/winter/level_1/object_1.png"),
				"shadow" = preload("res://assets/resources/buildings/storage/winter/level_1/shadow.png"),
			},
		}
	},
}

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& grid.mode == grid.modes.NOTHING\
	&& !blur.state\
	&& menu:
		inventory.open()
		menu = false
		if cursor:
			cursor.set_cursor(cursor.states.DEFAULT)

func _ready():
	update()
	shadow_create()

func update():
	if clock:
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("default"):
						if object[level]["seasons"][season]["default"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["default"]
							self.set_position(tilemap.map_to_local(Vector2i(22,2)))

func shadow_create() -> void:
	if visible:
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("shadow"):
						if object[level]["seasons"][season]["shadow"] is CompressedTexture2D:
							var vector2i_position = tilemap.local_to_map(position)
							var target_position = Vector2i(vector2i_position.x, vector2i_position.y+1)
							canvas.create_shadow("storage_shadow", object[level]["seasons"][season]["shadow"], target_position)

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING\
		&& distance < building.max_distance:
			if object.has(level):
				if object[level].has("seasons"):
					var season = clock.get_season()
					if object[level]["seasons"].has(season):
						if object[level]["seasons"][season].has("hovered"):
							if object[level]["seasons"][season]["hovered"] is CompressedTexture2D:
								sprite.texture = object[level]["seasons"][season]["hovered"]
			if !tip.visible:
				tip.tooltip(
						str(tr("object.storage.caption")) + "\n" +
						str(tr("object.storage.description")) + "\n" +
						str(tr("tip.object_level")) + ": " + str(level)
					)
	else:
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("default"):
						if object[level]["seasons"][season]["default"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["default"]
		if tip:
			if tip.visible:
				tip.tooltip("")

func get_data() -> Dictionary:
	if object.has(level):
		return {
			"level": level
			}
	return {}

func set_level_obj(obj_level:int) -> void:
	level = obj_level
	update()

func _on_area_2d_mouse_entered() -> void:
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& !buttonDestroy.destroyMode:
		_change_sprite(true)
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
	if !buttonDestroy.destroyMode:
		menu = true

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
	menu = false
	if cursor:
		cursor.set_cursor(cursor.states.DEFAULT)