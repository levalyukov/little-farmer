extends Node2D

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var sign_menu:Control = get_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var icon:TextureRect = $TextureRect
@onready var sprite:Sprite2D = $Sprite2D

var items = Items.new()
var max_distance:int = 250
var open_menu:bool = false
var object:Dictionary = {
	"description" = tr("sign.description"),
	"default" = load("res://assets/resources/buildings/sign/sign_0.png"),
	"hover" = load("res://assets/resources/buildings/sign/sign_1.png"),
}

func _ready():
	if object.has("default"):
		if typeof(object["default"]) == TYPE_OBJECT and sprite.texture is CompressedTexture2D:
			sprite.texture = object["default"]
		else:
			data.debug("The specified sprite cannot be installed.", "error")
	else:
		data.debug("The specified key is missing.", "error")

func set_sign_sprite(target_sprite):
	if items.content.has(target_sprite):
		if items.content[target_sprite].has("icon"):
			icon.texture = items.content[target_sprite]["icon"]
		else:
			data.debug("The object does not have the 'description' key", "error")
	else:
		data.debug("Invalid index: " + str(target_sprite), "error")

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
	return {
		"sprite_icon": icon.texture,
		"position": tilemap.local_to_map(position),
		}

func set_level(sprite_icon:CompressedTexture2D, node_position:Vector2) -> void:
	icon.texture = sprite_icon
	position = tilemap.map_to_local(node_position)

func _on_area_2d_mouse_entered() -> void:
	if !blur.state:
		_change_sprite(true)

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
