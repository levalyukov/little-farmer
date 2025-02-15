extends Node2D

@onready var main:String = GameData.main
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D
@onready var light:PointLight2D = $PointLight2D

var max_distance:int = 250
var level:int = 1
var blueprint_id:int
var vector:Vector2i
var object:Dictionary = {
	1: {
		"caption" = tr("christmas_tree.caption"),
		"description" = tr("christmas_tree.description"),
		"default" = load("res://assets/resources/buildings/christmass_tree/sprite_0.png"),
		"hover" = load("res://assets/resources/buildings/christmass_tree/sprite_1.png"),
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
			data.debug("There is no key at index " + str(level), "error")
	else:
		data.debug("Index " + str(level) + " is not in the dictionary.", "error")

func _process(_delta):
	if !pause.paused:
		if clock.hour >= 21:
			light.visible = true
		else:
			light.visible = false

func _change_sprite(type:bool):
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < max_distance:
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
			data.debug("There is no key at index " + str(level), "error")
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

func _on_collision_mouse_entered():
	if !blur.state:
		_change_sprite(true)

func _on_collision_mouse_exited():
	_change_sprite(false)
