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
@onready var canvas_group:CanvasGroup = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var tablet:Node2D = get_node("/root/"+main+"/ConstructionManager/tablet")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var sprite:Sprite2D = $Sprite2D

var object:Dictionary = {
	"seasons" = {
		"spring" = {
			"default" = preload("res://assets/resources/buildings/tablet/spring/object_0.png"),
			"hovered" = preload("res://assets/resources/buildings/tablet/spring/object_1.png"),
			"shadow" = preload("res://assets/resources/buildings/tablet/spring/shadow.png"),
		},
		"summer" = {
			"default" = preload("res://assets/resources/buildings/tablet/summer/object_0.png"),
			"hovered" = preload("res://assets/resources/buildings/tablet/summer/object_1.png"),
			"shadow" = preload("res://assets/resources/buildings/tablet/summer/shadow.png"),
		},
		"autumn" = {
			"default" = preload("res://assets/resources/buildings/tablet/autumn/object_0.png"),
			"hovered" = preload("res://assets/resources/buildings/tablet/autumn/object_1.png"),
			"shadow" = preload("res://assets/resources/buildings/tablet/autumn/shadow.png"),
		},
		"winter" = {
			"default" = preload("res://assets/resources/buildings/tablet/winter/object_0.png"),
			"hovered" = preload("res://assets/resources/buildings/tablet/winter/object_1.png"),
			"shadow" = preload("res://assets/resources/buildings/tablet/winter/shadow.png"),
		},
	}
}

func _ready():
	update()
	_change_sprite(false)

func update():
	if clock:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
						#	self.set_position(tilemap.map_to_local(Vector2i(46,5)))
						update_shadow()
					else:
						data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no '" + str(season) + "' key in the 'seasons' group.", "error")
		else:
			data.debug("'"+str(self.name) + "': There is no 'seasons' group.", "error")

func update_shadow() -> void:
	remove_shadow()
	if visible:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("shadow"):
					if object["seasons"][season]["shadow"] is CompressedTexture2D:
						var vector2i_position = tilemap.local_to_map(position)
						var target_position = Vector2i(vector2i_position.x, vector2i_position.y)
						canvas.create_shadow("tablet_shadow" + "_1", object["seasons"][season]["shadow"], target_position)
					else:
						data.debug("'"+str(self.name) + "': It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")

func remove_shadow():
	for i in canvas_group.get_children():
		if data.remove_suffix(i.name) == "tablet_shadow":
			canvas_group.remove_child(i)

func _change_sprite(type:bool) -> void:
	if type:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("hovered"):
					if object["seasons"][season]["hovered"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["hovered"]
						if main == "Village":
							sprite.flip_h = true
		if tip:
			if main == "Farm":
				tip.tooltip(
						tr("object.tablet.caption") + "\n" +
						tr("object.tablet.description_farm")
					)
			elif main == "Village":
				tip.tooltip(
						tr("object.tablet.caption") + "\n" +
						tr("object.tablet.description_city")
					)
	else:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
						if main == "Village":
							sprite.flip_h = true
		if tip:
			tip.tooltip("")

func _on_area_2d_mouse_entered() -> void:
	if visible:
		if !blur.state\
		&& grid.mode == grid.modes.NOTHING:
			if tablet:
				if round(tablet.global_position.distance_to(player.global_position)) < 100:
					_change_sprite(true)
					if cursor: 
						cursor.set_cursor(cursor.states.ACTIVE)

func _on_area_2d_mouse_exited() -> void:
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	_change_sprite(false)
