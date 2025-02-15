extends Node2D

@onready var main:String = GameData.main
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
@onready var sprite:Sprite2D = $Sprite2D

var menu:bool = false
var object:Dictionary = {
	"caption" = tr("Почтовый ящик"),
	"shadow" = load("res://assets/resources/buildings/mailbox/shadow.png"),
	"seasons" = {
		"spring" = {
			"default" = load("res://assets/resources/buildings/mailbox/spring/object_0.png"),
			"hovered" = load("res://assets/resources/buildings/mailbox/spring/object_1.png"),
		},
		"summer" = {
			"default" = load("res://assets/resources/buildings/mailbox/summer/object_0.png"),
			"hovered" = load("res://assets/resources/buildings/mailbox/summer/object_1.png"),
		},
		"autumn" = {
			"default" = load("res://assets/resources/buildings/mailbox/autumn/object_0.png"),
			"hovered" = load("res://assets/resources/buildings/mailbox/autumn/object_1.png"),
		},
		"winter" = {
			"default" = load("res://assets/resources/buildings/mailbox/winter/object_0.png"),
			"hovered" = load("res://assets/resources/buildings/mailbox/winter/object_1.png"),
		},
	}
}

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& menu:
		mailbox.open()

func _ready():
	update()
	update_shadow()

func update():
	if clock:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
						self.set_position(tilemap.map_to_local(Vector2i(15,2)))
					else:
						data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no '" + str(season) + "' key in the 'seasons' group.", "error")
		else:
			data.debug("'"+str(self.name) + "': There is no 'seasons' group.", "error")

func update_shadow() -> void:
	if visible:
		if object.has("shadow"):
			if object["shadow"] is CompressedTexture2D:
				var vector2i_position = tilemap.local_to_map(position)
				var target_position = Vector2i(vector2i_position.x, vector2i_position.y+1)
				canvas.create_shadow("mailbox_shadow", object["shadow"], target_position)
			else:
				data.debug("'"+str(self.name) + "': It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")

func _on_area_2d_mouse_entered() -> void:
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		var distance = round(global_position.distance_to(player.global_position))
		if distance < building.max_distance:
			if object.has("seasons"):
				var season = clock.get_season()
				if object["seasons"].has(season):
					if object["seasons"][season].has("hovered"):
						if object["seasons"][season]["hovered"] is CompressedTexture2D:
							sprite.texture = object["seasons"][season]["hovered"]
			if tip:
				tip.tooltip(
						str(object["caption"])
					)
		menu = true

func _on_area_2d_mouse_exited() -> void:
	if object.has("seasons"):
		var season = clock.get_season()
		if object["seasons"].has(season):
			if object["seasons"][season].has("default"):
				if object["seasons"][season]["default"] is CompressedTexture2D:
					sprite.texture = object["seasons"][season]["default"]
	if tip:
		tip.tooltip("")
	menu = false