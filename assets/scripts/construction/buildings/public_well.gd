extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var blueprintsShop:Control = get_node("/root/"+main+"/UI/Interactive/BlueprintsShop")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var sprite:Sprite2D = $Sprite2D

var audio = AudioStreamPlayer.new()
var openedMenu:bool = false
var object:Dictionary = {
	"shadow" = load("res://assets/resources/buildings/public_well/shadow.png"),
	"default" = load("res://assets/resources/buildings/public_well/obj_0.png"),
	"hovered" = load("res://assets/resources/buildings/public_well/obj_1.png"),
}

func _ready():
	self.visible = GameLoader.first_empty_water_can
	update()
	update_shadow()
	self.add_child(audio)

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& openedMenu\
	&& GameLoader.first_empty_water_can:
		if tools:
			if tools.water_can < tools.water_can_max:
				tools.water_can = tools.water_can_max
				if audio:
					if !audio.is_playing():
						audio.stream = load('res://assets/sounds/buildings/using_well.ogg')
						audio.play()
				if !tip.visible:
					tip.tooltip(
							str(tr('object.public_well.caption')) + "\n" +
							str(tr('object.public_well.description'))
						)

func update():
	if clock:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
		else:
			if object.has("default"):
				if object["default"] is CompressedTexture2D:
					sprite.texture = object["default"]
func update_shadow() -> void:
	if visible:
		if object.has("shadow"):
			if object["shadow"] is CompressedTexture2D:
				canvas.create_shadow("house_shadow", object["shadow"], tilemap.local_to_map(position))
func _on_area_2d_mouse_entered() -> void:
	openedMenu = true
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& GameLoader.first_empty_water_can:
		var distance = round(global_position.distance_to(player.global_position))
		if distance < building.max_distance:
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)
			if object.has("seasons"):
				var season = clock.get_season()
				if object["seasons"].has(season):
					if object["seasons"][season].has("hovered"):
						if object["seasons"][season]["hovered"] is CompressedTexture2D:
							sprite.texture = object["seasons"][season]["hovered"]
			else:
				if object.has("hovered"):
					if object["hovered"] is CompressedTexture2D:
						sprite.texture = object["hovered"]
					else:
						data.debug("'"+str(self.name) + "': 'hovered' is not a CompressedTexture2D.", "error")
				else:
					data.debug("'"+str(self.name) + "': There is no 'hovered' key.", "error")
			if tools:
				if tools.water_can < tools.water_can_max:
					if !tip.visible:
						tip.tooltip(
								str(tr('object.public_well.caption')) + "\n" +
								str(tr('object.public_well.description')) + '\n' +
								"- " + tr('object.well.opportunity_fill_watering_can')
							)
				else:
					if !tip.visible:
						tip.tooltip(
								str(tr('object.public_well.caption')) + "\n" +
								str(tr('object.public_well.description'))
						)
			else:
				if !tip.visible:
					tip.tooltip(
							str(tr('object.public_well.caption')) + "\n" +
							str(tr('object.public_well.description'))
						)

func _on_area_2d_mouse_exited() -> void:
	openedMenu = !true
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if object.has("seasons"):
		var season = clock.get_season()
		if object["seasons"].has(season):
			if object["seasons"][season].has("default"):
				if object["seasons"][season]["default"] is CompressedTexture2D:
					sprite.texture = object["seasons"][season]["default"]
	else:
		if object.has('default'):
			if object['default'] is CompressedTexture2D:
				sprite.texture = object['default']
	if tip:
		tip.tooltip("")
