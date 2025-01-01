extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var sign_menu:Control = get_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var icon:TextureRect = $TextureRect
@onready var sprite:Sprite2D = $Sprite2D

var items = Items.new()
var sprite_id:int = 0
var blueprint_id:int = 0
var max_distance:int = 250
var open_menu:bool = false
var object:Dictionary = {
	"description" = tr("sign.description"),
	"default" = load("res://assets/resources/buildings/sign/sign_0.png"),
	"hover" = load("res://assets/resources/buildings/sign/sign_1.png"),
	"shadow" = load("res://assets/resources/buildings/sign/shadow.png"),
}

func _ready():
	update()

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
		if object:
			if object.has("shadow"):
				if object["shadow"] is CompressedTexture2D:
					var vector2i_position = tilemap.local_to_map(position)
					var target_position = Vector2i(vector2i_position.x, vector2i_position.y)
					canvas.create_shadow("sign_shadow", object["shadow"], target_position)
				else:
					data.debug("It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")

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
			_check_sprite("hover")
			open_menu = true
	else:
		_check_sprite("default")
		tip.tooltip("")
		open_menu = false
	
func _check_sprite(key:String) -> void:
	if object.has(key):
		if typeof(object[key]) == TYPE_OBJECT and sprite.texture is CompressedTexture2D:
			sprite.texture = object[key]
		else:
			data.debug("The specified sprite cannot be installed.", "error")
	else:
		data.debug("The specified key is missing.", "error")

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
	&& grid.mode == grid.modes.NOTHING:
		_change_sprite(true)

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
