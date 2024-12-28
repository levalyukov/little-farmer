extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var sprite:Sprite2D = $Sprite2D

var level:int = 1
var blueprint_id:int = 0
var object:Dictionary = {
	1: {
		"caption" = tr("animalstall.caption"),
		"description" = tr("animalstall.description"),
		"default" = load("res://assets/resources/buildings/stall/object_0.png"),
		"hover" = load("res://assets/resources/buildings/stall/object_1.png"),
	},
}

func _ready():
	update()

func update():
	if object.has(level):
		if object[level].has("default"):
			if sprite:
				sprite.texture = object[level]["default"]
		else:
			data.debug("There is no key at index " + str(level) + ".", "error")
	else:
		data.debug("Index " + str(level) + " is not in the dictionary.", "error")

func _change_sprite(type:bool):
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < building.max_distance:
			if object.has(level):
				_check_sprite("hover")
				var level_text = tr("object.level")
				tip.tooltip(
					str(object[level]["caption"]) + "\n" +
					str(object[level]["description"]) + "\n" +
					str(level_text) + str(level)
					)
	else:
		_check_sprite("default")
		if tip:
			tip.tooltip("")

func _check_sprite(key:String):
	if object.has(level):
		if object[level].has(key):
			if object[level][key] is CompressedTexture2D:
				if sprite:
					sprite.texture = object[level][key]
			else:
				data.debug("The specified sprite cannot be installed.", "error")
		else:
			data.debug("There is no key at index " + str(level) + ".", "error")
	else:
		data.debug("Index " + str(level) + " is not in the dictionary.", "error")

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

func _on_area_2d_mouse_entered():
	if !blur.state:
		_change_sprite(true)

func _on_area_2d_mouse_exited():
	_change_sprite(false)
