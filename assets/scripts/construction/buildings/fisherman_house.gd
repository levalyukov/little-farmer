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
@onready var tradeMenu:Control = get_node("/root/"+main+"/UI/Interactive/TradeMenu")
@onready var chimney:CPUParticles2D = $CPUParticles2D
@onready var sprite:Sprite2D = $Sprite2D

const bakeMorningOn:int = 5
const bakeMorningOff:int = 8
const bakeEveninggOn:int = 19
const bakeEveninggOff:int = 22
#	var openedTradeMenu:bool = false
var object:Dictionary = {
	"shadow" = load("res://assets/resources/buildings/fisherman_house/shadow.png"),
	"default" = load("res://assets/resources/buildings/fisherman_house/object_0.png"),
	"hovered" = load("res://assets/resources/buildings/fisherman_house/object_1.png"),
}

func _ready():
	update()
	update_shadow()

#	func _input(event):
#		if event is InputEventMouseButton\
#		&& event.button_index == MOUSE_BUTTON_LEFT\
#		&& event.is_pressed()\
#		&& !blur.state\
#		&& grid.mode == grid.modes.NOTHING\
#		&& openedTradeMenu:
#			tradeMenu.open_trade_menu(1)
#			update()

func update():
	if clock:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
						self.set_position(tilemap.map_to_local(Vector2i(13,21)))
					else:
						data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no '" + str(season) + "' key in the 'seasons' group.", "error")
		else:
			if object.has("default"):
				if object["default"] is CompressedTexture2D:
					sprite.texture = object["default"]
					self.set_position(tilemap.map_to_local(Vector2i(13,21)))
				else:
					data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no 'default' key.", "error")

func update_shadow() -> void:
	if visible:
		if object.has("shadow"):
			if object["shadow"] is CompressedTexture2D:
				var vector2i_position = tilemap.local_to_map(position)
				var target_position = Vector2i(vector2i_position.x, vector2i_position.y)
				canvas.create_shadow("house_shadow", object["shadow"], target_position)
			else:
				data.debug("'"+str(self.name) + "': It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")

func _process(_delta):
	if pause.paused:
		if chimney.speed_scale > 0:
			chimney.speed_scale = 0
	else:
		var tt = clock.get_hour() # target_time
		if (tt >= bakeMorningOn && tt < bakeMorningOff) || (tt >= bakeEveninggOn && tt < bakeEveninggOff):
			chimney.emitting = true
		else:
			chimney.emitting = false

		if chimney.emitting:
			if chimney.speed_scale == 0:
				chimney.speed_scale = 0.5

func _on_area_2d_mouse_entered() -> void:
	#	openedTradeMenu = true
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
						else:
							data.debug()
					else:
						data.debug()
				else:
					data.debug()
			else:
				if object.has("hovered"):
					if object["hovered"] is CompressedTexture2D:
						sprite.texture = object["hovered"]
					else:
						data.debug("'"+str(self.name) + "': 'hovered' is not a CompressedTexture2D.", "error")
				else:
					data.debug("'"+str(self.name) + "': There is no 'hovered' key.", "error")
			tip.tooltip(tr("object.fisherman_house.caption"))

func _on_area_2d_mouse_exited() -> void:
	#	openedTradeMenu = !true
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
