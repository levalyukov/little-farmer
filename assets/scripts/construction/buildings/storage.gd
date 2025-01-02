extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
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
@onready var sprite:Sprite2D = $Sprite2D

var menu:bool = false
var level:int = 1
var object:Dictionary = {
	1: {
		"caption" = tr("storage.caption"),
		"description" = tr("storage.description"),
		"slots" = 12,
		"seasons" = {
			"spring" = {
				"default" = load(""),
				"hovered" = load(""),
			},
			"summer" = {
				"default" = load("res://assets/resources/buildings/storage/summer/level_1/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/storage/summer/level_1/object_1.png"),
				"shadow" = load("res://assets/resources/buildings/storage/summer/level_1/shadow.png"),
			},
			"autumn" = {
				"default" = load(""),
				"hovered" = load(""),
			},
			"winter" = {
				"default" = load("res://assets/resources/buildings/storage/winter/level_1/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/storage/winter/level_1/object_1.png"),
				"shadow" = load("res://assets/resources/buildings/storage/winter/level_1/shadow.png"),
			},
		}
	},
}

func _input(event):
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT\
	and menu:
		inventory.open()
		menu = false

func _ready():
	update()

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
							shadow_create()
						else:
							data.debug("'default' is not a CompressedTexture2D.", "error")
					else:
						data.debug("There is no key at index " + str(level), "error")
				else:
					data.debug("There is no '" + str(season) + "' key in the 'seasons' group.", "error")
			else:
				data.debug("There is no 'seasons' group.", "error")
		else:
			data.debug("Index " + str(level) + " is not in the dictionary.", "error")

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
							canvas.create_shadow("house_shadow", object[level]["seasons"][season]["shadow"], target_position)
						else:
							data.debug("It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")
					else:
						data.debug("The 'shadow' key with index level "+str(level)+" is missing.", "error")
				else:
					pass
			else:
				pass
		else:
			data.debug("Invalid level index: "+str(level), "error")

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING\
		&& distance < building.max_distance:
			var level_text = tr("object.level")
			tip.tooltip(
					str(object[level]["caption"]) + "\n" +
					str(object[level]["description"]) + "\n" +
					str(level_text) + str(level)
				)
	else:
		if tip:
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
	&& grid.mode == grid.modes.NOTHING:
		_change_sprite(true)
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("hovered"):
						if object[level]["seasons"][season]["hovered"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["hovered"]
	menu = true

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
	if object.has(level):
		if object[level].has("seasons"):
			var season = clock.get_season()
			if object[level]["seasons"].has(season):
				if object[level]["seasons"][season].has("default"):
					if object[level]["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object[level]["seasons"][season]["default"]
	menu = false