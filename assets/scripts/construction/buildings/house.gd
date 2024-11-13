extends Node2D

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridCollision")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var fume:GPUParticles2D = $GPUParticles2D
@onready var ext:Sprite2D = $Sprite2D_2
@onready var sprite:Sprite2D = $Sprite2D

const name_:String = "house"
var level:int = 1
var object:Dictionary = {
	1: {
		"caption" = tr("house_lvl1.caption"),
		"description" = tr("house_lvl1.description"),
		"default" = load("res://assets/resources/buildings/house/level_1/object_0.png"),
		"hover" = load("res://assets/resources/buildings/house/level_1/object_1.png"),
		"shadow" = load("res://assets/resources/buildings/house/level_1/shadow.png"),
	},
	2: {
		"caption" = tr("house_lvl2.caption"),
		"description" = "house_lvl2.description.",
		"fume" 	= true,
		"default" = load("res://assets/resources/buildings/house/level_2/object_0.png"),
		"hover" = load("res://assets/resources/buildings/house/level_2/object_1.png"),
		"ext_default" = load("res://assets/resources/buildings/house/level_2/ext_0.png"),
		"ext_hover"= load("res://assets/resources/buildings/house/level_2/ext_1.png"),
		"shadow" = load(""),
	}
}

func _ready():
	update()
	_shadow_create()

func update():
	if object.has(level):
		if object[level].has("default"):
			sprite.texture = object[level]["default"]
			_check_key("fume")
			_check_key("ext")
				
		else:
			data.debug("There is no key at index " + str(level), "error")
	else:
		data.debug("Index " + str(level) + " is not in the dictionary.", "error")

func _shadow_create() -> void:
	if visible:
		if object.has(level):
			if object[level].has("shadow"):
				if object[level]["shadow"] is CompressedTexture2D:
					var vector2i_position = tilemap.local_to_map(position)
					var target_position = Vector2i(vector2i_position.x, vector2i_position.y+1)
					canvas.create_shadow("house_shadow", object[level]["shadow"], target_position)
				else:
					data.debug("It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")
			else:
				data.debug("The 'shadow' key with index level "+str(level)+" is missing.", "error")
		else:
			data.debug("Invalid level index: "+str(level), "error")

func _check_key(key:String) -> void:
	match key:
		"fume":
			fume.emitting = object[level].has(key)
			fume.visible = object[level].has(key)
		"ext":
			if object[level].has("ext_default"):
				if (object[level]["ext_default"] && object[level]["ext_hover"]) is CompressedTexture2D:
					if ext:
						ext.visible = true
				else:
					if ext:
						ext.visible = false

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < building.max_distance:
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

func _check_sprite(key:String) -> void:
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
			"level": level
			}
	return {}

func set_level_obj(obj_level:int) -> void:
	level = obj_level
	update()

func _on_area_2d_mouse_entered() -> void:
	if !blur.state:
		_change_sprite(true)

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
