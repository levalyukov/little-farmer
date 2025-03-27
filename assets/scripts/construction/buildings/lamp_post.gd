extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D
@onready var light:PointLight2D = $Light

var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var blueprint_id:int = 0
var object:Dictionary = {
	"shadow" = load("res://assets/resources/buildings/lamp_post/shadow.png"),
	"idle" = load("res://assets/resources/buildings/lamp_post/object_0.png"),
	"lighting" = load("res://assets/resources/buildings/lamp_post/object_1.png"),
	"idle_delete" = load("res://assets/resources/buildings/lamp_post/object_2.png"),
	"lighting_delete" = load("res://assets/resources/buildings/lamp_post/object_3.png"),
}

const lightOn:int = 19
const lightOff:int = 5

func _ready():
	update()

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		buildings.remove_node(self, all_collisions)

func update():
	if clock:
		if !light.visible:
			if object.has("idle"):
				if object["idle"] is CompressedTexture2D:
					sprite.texture = object["idle"]
				else:
					data.debug("'"+str(self.name) + "': 'idle' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no 'idle' key.", "error")
		else:
			if object.has("lighting"):
				if object["lighting"] is CompressedTexture2D:
					sprite.texture = object["lighting"]
				else:
					data.debug("'"+str(self.name) + "': 'lighting' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no 'lighting' key.", "error")

func _process(_delta):
	if light\
	&& clock:
		var target_hour = clock.get_hour()
		if target_hour >= lightOn || (target_hour < lightOff ) :
			if !light.visible:
				light.visible = true
				update()
		if target_hour >= lightOff && target_hour < lightOn:
			if light.visible:
				light.visible = false
				update()
		
func get_data() -> Dictionary:
	return {
		"value": light.visible,
		"position": tilemap.local_to_map(position),
		"id": blueprint_id,
		'all_collisions': all_collisions
		}

func _on_area_2d_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& buttonDestroy.destroyMode:
		destroyMode = true
		if light.visible:
			if object.has("lighting_delete"):
				if object["lighting_delete"] is CompressedTexture2D:
					sprite.texture = object["lighting_delete"]
		else:
			if object.has("idle_delete"):
				if object["idle_delete"] is CompressedTexture2D:
					sprite.texture = object["idle_delete"]

func _on_area_2d_mouse_exited():
	if buttonDestroy.destroyMode:
		destroyMode = !true
		if light.visible:
			if object.has("lighting"):
				if object["lighting"] is CompressedTexture2D:
					sprite.texture = object["lighting"]
		else:
			if object.has("idle"):
				if object["idle"] is CompressedTexture2D:
					sprite.texture = object["idle"]
	else:
		if light.visible:
			if object.has("lighting"):
				if object["lighting"] is CompressedTexture2D:
					sprite.texture = object["lighting"]
		else:
			if object.has("idle"):
				if object["idle"] is CompressedTexture2D:
					sprite.texture = object["idle"]
