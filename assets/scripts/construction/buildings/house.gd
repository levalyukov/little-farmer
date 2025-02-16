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
@onready var sprite:Sprite2D = $Sprite2D

var menu:bool = false
var level:int = 1
var object:Dictionary = {
	1: {
		"caption" = tr("Дом"),
		"description" = tr("Старый и уютный деревянный домик."),
		"shadow" = load("res://assets/resources/buildings/house/shadow.png"),
		"seasons" = {
			"spring" = {
				"default" = load("res://assets/resources/buildings/house/spring/level_1/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/house/spring/level_1/object_1.png"),
			},
			"summer" = {
				"default" = load("res://assets/resources/buildings/house/summer/level_1/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/house/summer/level_1/object_1.png"),
			},
			"autumn" = {
				"default" = load("res://assets/resources/buildings/house/autumn/level_1/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/house/autumn/level_1/object_1.png"),
			},
			"winter" = {
				"default" = load("res://assets/resources/buildings/house/winter/level_1/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/house/winter/level_1/object_1.png"),
			},
		}
	},
}

func _ready():
	update()
	update_shadow()

func update():
	if clock:
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("default"):
						if object[level]["seasons"][season]["default"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["default"]
							self.set_position(tilemap.map_to_local(Vector2i(18,2)))
						else:
							data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
					else:
						data.debug("'"+str(self.name) + "': There is no key at index " + str(level), "error")
				else:
					data.debug("'"+str(self.name) + "': There is no '" + str(season) + "' key in the 'seasons' group.", "error")
			else:
				if object[level].has("default"):
					if object[level]["default"] is CompressedTexture2D:
						sprite.texture = object[level]["default"]
						self.set_position(tilemap.map_to_local(Vector2i(18,2)))
					else:
						data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
				else:
					data.debug("'"+str(self.name) + "': There is no 'default' key.", "error")
		else:
			data.debug("'"+str(self.name) + "': Index " + str(level) + " is not in the dictionary.", "error")

func update_shadow() -> void:
	if visible:
		if object.has(level):
			if object[level].has("shadow"):
				if object[level]["shadow"] is CompressedTexture2D:
					var vector2i_position = tilemap.local_to_map(position)
					var target_position = Vector2i(vector2i_position.x, vector2i_position.y+1)
					canvas.create_shadow("house_shadow", object[level]["shadow"], target_position)
				else:
					data.debug("'"+str(self.name) + "': It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")
			else:
				data.debug("'"+str(self.name) + "': The 'shadow' key with index level "+str(level)+" is missing.", "error")
		else:
			data.debug("'"+str(self.name) + "': Invalid level index: "+str(level), "error")

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < building.max_distance:
			if object.has(level):
				if object[level].has("seasons"):
					var season = clock.get_season()
					if object[level]["seasons"].has(season):
						if object[level]["seasons"][season].has("hovered"):
							if object[level]["seasons"][season]["hovered"] is CompressedTexture2D:
								sprite.texture = object[level]["seasons"][season]["hovered"]
							else:
								data.debug()
						else:
							data.debug()
					else:
						data.debug()
				else:
					if object[level].has("hovered"):
						if object[level]["hovered"] is CompressedTexture2D:
							sprite.texture = object[level]["hovered"]
						else:
							data.debug("'"+str(self.name) + "': 'hovered' is not a CompressedTexture2D.", "error")
					else:
						data.debug("'"+str(self.name) + "': There is no 'hovered' key.", "error")
			var level_text = tr("Уровень")
			tip.tooltip(
					str(object[level]["caption"]) + "\n" +
					str(object[level]["description"]) + "\n" +
					str(level_text) + ": " + str(level)
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

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
