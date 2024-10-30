extends Node2D

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/" + main)
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var sprite:Sprite2D = $Sprite2D

const name_:String = "Mailbox"
var open_menu:bool = false
var object:Dictionary = {
	"caption" = tr("mailbox.caption"),
	"description" = tr("mailbox.description"),
	"default" = load("res://assets/resources/buildings/mailbox/object_0.png"),
	"hover" = load("res://assets/resources/buildings/mailbox/object_1.png"),
	"shadow" = load("res://assets/resources/buildings/mailbox/shadow.png")
}

func _ready():
	update()
	_shadow_create()

func _input(event):
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT\
	and event.is_pressed()\
	and !blur.state\
	and open_menu:
		mailbox.open()

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
		if object.has("shadow"):
			if object["shadow"] is CompressedTexture2D:
				var vector2i_position = tilemap.local_to_map(position)
				var target_position = Vector2i(vector2i_position.x, vector2i_position.y)
				canvas.create_shadow("mailbox_shadow", object["shadow"], target_position)
			else:
				data.debug("It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")
		else:
			data.debug("The 'shadow' element is missing", "error")

func _change_sprite(type:bool) -> void:
	if type:
		var distance = round(global_position.distance_to(player.global_position))
		if grid.mode == grid.modes.NOTHING and distance < building.max_distance:
			_check_sprite("hover")
			if object.has("caption")\
			and object.has("description"):
				tip.tooltip(
					object["caption"]+"\n"
					+object["description"]
				)
				open_menu = true
			else:
				data.debug("Check the 'caption', 'description' elements", "error")
	else:
		_check_sprite("default")
		open_menu = false
		if tip:
			tip.tooltip("")
	
func _check_sprite(key:String) -> void:
	if object.has(key):
		if object[key] is CompressedTexture2D:
			if sprite:
				sprite.texture = object[key]
		else:
			data.debug("The specified sprite cannot be installed", "error")
	else:
		data.debug("The specified key is missing", "error")

func _on_area_2d_mouse_entered() -> void:
	if !blur.state:
		_change_sprite(true)

func _on_area_2d_mouse_exited() -> void:
	_change_sprite(false)
