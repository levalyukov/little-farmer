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
@onready var dialogWindow:Control = get_node("/root/"+main+"/UI/Interactive/DialogWindow")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var chimney:CPUParticles2D = $CPUParticles2D
@onready var sprite:Sprite2D = $Sprite2D

const bakeMorningOn:int = 5
const bakeMorningOff:int = 8
const bakeEveninggOn:int = 19
const bakeEveninggOff:int = 22
var openedMenu:bool = false
var object:Dictionary = {
	"caption" = tr("Дом плотника Вэнси"),
	"shadow" = load("res://assets/resources/buildings/carpenter_house/shadow.png"),
	"default" = load("res://assets/resources/buildings/carpenter_house/obj_0.png"),
	"hovered" = load("res://assets/resources/buildings/carpenter_house/obj_1.png"),
}

func _ready():
	update()
	update_shadow()

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& openedMenu:
		dialogWindow.dialogWindow(
			"Дом плотника Вэнса",
			[
				'Перед вами стоит старый домик плотника Вэнса.\n\nВойдя в дом, Вэнс вас радостно встречает и предлагает вам свои услуги:' 
			], 
			{
				0:['Приобрести чертежи','Купить ресурсов', 'Уйти'],
			},
			{
				0:[3,2,0],
				1:[0],
			},
			3
			)
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)
		update()

func update():
	if clock:
		if object.has("seasons"):
			var season = clock.get_season()
			if object["seasons"].has(season):
				if object["seasons"][season].has("default"):
					if object["seasons"][season]["default"] is CompressedTexture2D:
						sprite.texture = object["seasons"][season]["default"]
						self.set_position(tilemap.map_to_local(Vector2i(21,-3)))
					else:
						data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no '" + str(season) + "' key in the 'seasons' group.", "error")
		else:
			if object.has("default"):
				if object["default"] is CompressedTexture2D:
					sprite.texture = object["default"]
					self.set_position(tilemap.map_to_local(Vector2i(21,-3)))
				else:
					data.debug("'"+str(self.name) + "': 'default' is not a CompressedTexture2D.", "error")
			else:
				data.debug("'"+str(self.name) + "': There is no 'default' key.", "error")

func update_shadow() -> void:
	if visible:
		if object.has("shadow"):
			if object["shadow"] is CompressedTexture2D:
				canvas.create_shadow("carpenter_shadow", object["shadow"], tilemap.local_to_map(position))
			else:
				data.debug("'"+str(self.name) + "': It is not possible to create a game shadow of an object because the sprite is not of the 'CompressedTexture2D' type.", "error")

func _process(_delta) -> void:
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
	openedMenu = true
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
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
			tip.tooltip(
					str(object["caption"])
				)

func _on_area_2d_mouse_exited() -> void:
	openedMenu = !true
	if !blur.state: if cursor: cursor.set_cursor(cursor.states.DEFAULT)
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
