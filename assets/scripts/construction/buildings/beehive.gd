extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var buildings:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var buttonDestroy:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools/Tool/MarginContainer/MarginContainer/HBoxContainer/ButtonDestroyMenu")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")

@onready var _sound:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var _anim:AnimationPlayer = $AnimationPlayer
@onready var _indicator:Sprite2D = $Indicator
@onready var _sprite:Sprite2D = $Sprite2D

var blueprint_id:int = 0
var destroyMode:bool = false
var all_collisions:Array[Vector2i] = []
var sprite_coords:Vector2i

var hovered:bool = false

var honeyReady:bool = false
var value:int = 0

var _UIAudio:AudioStreamPlayer

var _texture:Dictionary = {
	'spring': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_spring.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_spring_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_spring_delete.png")
	},
	'summer': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_summer.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_summer_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_summer_delete.png")
	},
	'autumn': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_autumn.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_autumn_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_autumn_delete.png")
	},
	'winter': {
		'default': preload("res://assets/resources/buildings/beehive/beehive_winter.png"),
		'hover': preload("res://assets/resources/buildings/beehive/beehive_winter_hover.png"),
		'delete': preload("res://assets/resources/buildings/beehive/beehive_winter_delete.png")
	},
}


func _ready():
	_UIAudio = AudioStreamPlayer.new()
	_UIAudio.stream = preload('res://assets/sounds/buildings/beehive_honey.ogg')
	self.add_child(_UIAudio)

	if _texture: if _texture.has(clock.get_season()): _sprite.texture = _texture[clock.get_season()]["default"]
	farming.add_beehive(self, tilemap.local_to_map(self.position))
	_update_sound()
	_update_indicator()

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& destroyMode\
	&& buttonDestroy.destroyMode:
		farming.remove_beehive(self.name)
		if !farming.has_beehive(self.name):
			buildings.remove_node(self, all_collisions)

	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& hovered\
	&& honeyReady:
		_UIAudio.play()
		inventory.add_item(64, 1)
		honeyReady = false
		_update_indicator()

func _update_indicator() -> void:
	if honeyReady:
		if !_indicator.visible:
			_indicator.visible = true
			if _anim: _anim.play('new_animation')
	else:
		if _indicator.visible:
			_indicator.visible = !true
			if _anim: _anim.stop()

func _update_sound() -> void:
	if clock.get_season() == "winter": 
		_sound.stop()
	else: 
		_sound.play()

func _on_area_2d_mouse_exited():
	if destroyMode: destroyMode = !true
	if _texture.has(clock.get_season()):
		if _texture[clock.get_season()]["default"] is CompressedTexture2D:
			_sprite.texture = _texture[clock.get_season()]["default"]
			hovered = false
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if tip: if tip.visible: tip.tooltip()

func _on_area_2d_mouse_entered():
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if buttonDestroy.destroyMode:
			destroyMode = true
			if _texture.has(clock.get_season()):
				if _texture[clock.get_season()].has("delete") && _texture[clock.get_season()]["delete"] is CompressedTexture2D:
					_sprite.texture = _texture[clock.get_season()]["delete"]
		else:
			hovered = true
			_sprite.texture = _texture[clock.get_season()]["hover"]
			if tip: if !tip.visible: tip.tooltip(
				tr('object.beehive.caption') + "\n" +
				""
				)
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
	
func get_data() -> Dictionary:
	return {
		"position": tilemap.local_to_map(self.position),
		"id": blueprint_id,
		'all_collisions': all_collisions,
		'honey_ready': honeyReady,
		'value': value
	}