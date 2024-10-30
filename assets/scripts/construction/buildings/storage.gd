extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var sprite:Sprite2D = $Sprite2D

const name_:String = "Storage"
var menu:bool = false
var level:int = 1
var object:Dictionary = {
	1: {
		"caption" = tr("storage_lvl1.caption"),
		"description" = tr("storage_lvl1.description"),
		"slots" = 12,
		"default" = load("res://assets/resources/buildings/storage/level_1/object_0.png"),
		"hover" = load("res://assets/resources/buildings/storage/level_1/object_1.png"),
		"shadow" = load("res://assets/resources/buildings/storage/level_1/shadow.png"),
	},
	2: {
		"caption" = tr("storage_lvl2.caption"),
		"description" = tr("storage_lvl2.description"),
		"slots" = 24,
		"default" = load("res://assets/resources/buildings/storage/level_2/object_0.png"),
		"hover" = load("res://assets/resources/buildings/storage/level_2/object_1.png"),
		"shadow" = load("res://assets/resources/buildings/storage/level_2/shadow.png"),
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
	_shadow_create()

func update() -> void:
	if object.has("default"):
		if typeof(object["default"]) == TYPE_OBJECT and sprite.texture is CompressedTexture2D:
			sprite.texture = object["default"]
		else:
			data.debug("The specified sprite cannot be installed.", "error")
	else:
		data.debug("The specified key is missing.", "error")

func _shadow_create() -> void:
	if visible:
		if object.has(level):
			if object[level].has("shadow"):
				if object[level]["shadow"] is CompressedTexture2D:
					var vector2i_position = tilemap.local_to_map(position)
					var target_position = Vector2i(vector2i_position.x, vector2i_position.y)
					canvas.create_shadow("storage_shadow", object[level]["shadow"], target_position)
				else:
					data.debug("It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")
			else:
				data.debug("The 'shadow' key with index level "+str(level)+" is missing.", "error")
		else:
			data.debug("Invalid level index: "+str(level), "error")

func _change_sprite(type:bool):
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < buildings.max_distance:
			_check_sprite("hover")
			var level_text = tr("object.level")
			tip.tooltip(
				str(object[level]["caption"]) + "\n" +
				str(object[level]["description"]) + "\n" +
				str(level_text) + str(level)
				)
			menu = true
	else:
		_check_sprite("default")
		menu = false
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

func get_data():
	if object.has(level):
		return {"level": level}

func load_data(obj_level:int) -> void:
	self.level = obj_level
	update()

func _on_area_2d_mouse_entered():
	if !blur.state:
		_change_sprite(true)

func _on_area_2d_mouse_exited():
	_change_sprite(false)
