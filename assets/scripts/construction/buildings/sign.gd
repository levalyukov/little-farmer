extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var sign_menu:Control = get_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var icon:TextureRect = $TextureRect
@onready var sprite:Sprite2D = $Sprite2D

const level:int = 0

var items = Items.new()
var sprite_id:int = 0
var blueprint_id:int = 0
var max_distance:int = 250
var open_menu:bool = false
var vector:Vector2i
var object:Dictionary = {
	0: {
		"seasons" = {
			"spring" = {
				"default" = load("res://assets/resources/buildings/sign/spring/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/sign/spring/object_1.png"),
				"delete" = load("res://assets/resources/buildings/sign/spring/object_2.png")
			},
			"summer" = {
				"default" = load("res://assets/resources/buildings/sign/summer/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/sign/summer/object_1.png"),
				"delete" = load("res://assets/resources/buildings/sign/summer/object_2.png")
			},
			"autumn" = {
				"default" = load("res://assets/resources/buildings/sign/autumn/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/sign/autumn/object_1.png"),
				"delete" = load("res://assets/resources/buildings/sign/autumn/object_2.png")
			},
			"winter" = {
				"default" = load("res://assets/resources/buildings/sign/winter/object_0.png"),
				"hovered" = load("res://assets/resources/buildings/sign/winter/object_1.png"),
				"delete" = load("res://assets/resources/buildings/sign/winter/object_2.png")
			},
		}
	}
}

func _ready():
	update()

func update() -> void:
	if clock:
		if object[level].has("seasons"):
			var season = clock.get_season()
			if object[level]["seasons"].has(season):
				if object[level]["seasons"][season].has("default"):
					if object[level]["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object[level]["seasons"][season]["default"]

func set_sign_sprite(item_id):
	sprite_id = item_id
	if icon:
		if items.content.has(int(item_id)):
			if items.content[int(item_id)].has("icon"):
				icon.texture = items.content[int(item_id)]["icon"]
			else:
				data.debug("The object does not have the 'description' key", "error")
		else:
			data.debug("Invalid index: " + str(item_id), "error")

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& open_menu:
		sign_menu._open(name)

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < max_distance:
			if clock:
				if object[level].has("seasons"):
					var season = clock.get_season()
					if object[level]["seasons"].has(season):
						if object[level]["seasons"][season].has("hovered"):
							if object[level]["seasons"][season]["hovered"] is CompressedTexture2D:
								sprite.texture = object[level]["seasons"][season]["hovered"]
			open_menu = true
	else:
		if clock:
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("default"):
						if object[level]["seasons"][season]["default"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["default"]
		tip.tooltip("")
		open_menu = false

func get_data() -> Dictionary:
	if sprite_id != 0 && items.content.has(sprite_id):
		return {
			"sprite_id": sprite_id,
			"id": blueprint_id,
			"position": tilemap.local_to_map(position),
			}
	else:
		return {
			"id": blueprint_id,
			"position": tilemap.local_to_map(position),
			}

func _on_area_2d_mouse_entered() -> void:
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& !buttonDestroy.destroyMode:
		_change_sprite(true)
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& buttonDestroy.destroyMode:
		if object.has(level):
			if object[level].has("seasons"):
				var season = clock.get_season()
				if object[level]["seasons"].has(season):
					if object[level]["seasons"][season].has("delete"):
						if object[level]["seasons"][season]["delete"] is CompressedTexture2D:
							sprite.texture = object[level]["seasons"][season]["delete"]

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
