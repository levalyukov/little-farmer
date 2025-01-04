extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var pause:Control = get_node("/root/"+main+"/UI/Inveractive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var sprite:Sprite2D = $Sprite2D

var max_distance:int = 250
var level:int = 1
var blueprint_id:int
var vector:Vector2i
var object:Dictionary = {
	1: {
		"caption" = tr("silo.caption"),
		"description" = tr("silo.description"),
		"shadow" = load("res://assets/resources/buildings/silo/level_1/shadow.png"),
		"seasons" = {
			"spring" = {
				"default" = load("res://assets/resources/buildings/silo/level_1/spring/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/silo/level_1/spring/object_1.png"),
			},
			"summer" = {
				"default" = load("res://assets/resources/buildings/silo/level_1/summer/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/silo/level_1/summer/object_1.png"),
			},
			"autumn" = {
				"default" = load("res://assets/resources/buildings/silo/level_1/autumn/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/silo/level_1/autumn/object_1.png"),
			},
			"winter" = {
				"default" = load("res://assets/resources/buildings/silo/level_1/winter/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/silo/level_1/winter/object_1.png"),
			},
		}
	},
}

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

func _change_sprite(type:bool):
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < max_distance:
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
				var level_text = tr("object.level")
				tip.tooltip(
					str(object[level]["caption"]) + "\n" +
					str(object[level]["description"]) + "\n" +
					str(level_text) + str(level)
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
			"id": blueprint_id,
			"position": tilemap.local_to_map(position),
			"level": level
		}
	return {}

func load_data(obj_level:int) -> void:
	self.level = obj_level
	update()

func _on_collision_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		_change_sprite(true)

func _on_collision_mouse_exited():
	_change_sprite(false)
