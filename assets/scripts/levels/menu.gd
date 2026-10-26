extends Node2D

@onready var shadow: CanvasGroup = $ShadowContainer
@onready var cycle: CanvasModulate = $CanvasModulate
@onready var tilemap: TileMap = $TileMap
@onready var nature: Node2D = $NatureContainer
@onready var canvas: CanvasGroup = $Clouds

@export var house: Sprite2D
@export var mailbox: Sprite2D
@export var storage: Sprite2D

var clouds_spawner: Timer
var clouds_updater: Timer
var clouds: Dictionary = {}
const CLOUDS_COORDS: Array[Vector2i] = [Vector2i(23, 13), Vector2i(56, 34)]

const SPRING_GROUND: CompressedTexture2D = preload("res://assets/resources/world/landscape/spring/ground.png")
const SUMMER_GROUND: CompressedTexture2D = preload("res://assets/resources/world/landscape/summer/ground.png")
const AUTUMN_GROUND: CompressedTexture2D = preload("res://assets/resources/world/landscape/autumn/ground.png")
const WINTER_GROUND: CompressedTexture2D = preload("res://assets/resources/world/landscape/winter/ground.png")
const SPRING_ROADS: CompressedTexture2D = preload("res://assets/resources/world/landscape/spring/roads.png")
const SUMMER_ROADS: CompressedTexture2D = preload("res://assets/resources/world/landscape/summer/roads.png")
const AUTUMN_ROADS: CompressedTexture2D = preload("res://assets/resources/world/landscape/autumn/roads.png")
const WINTER_ROADS: CompressedTexture2D = preload("res://assets/resources/world/landscape/winter/roads.png")
const SPRING_FARMLANDS: CompressedTexture2D = preload("res://assets/resources/world/landscape/spring/farmlands.png")
const SUMMER_FARMLANDS: CompressedTexture2D = preload("res://assets/resources/world/landscape/summer/farmlands.png")
const AUTUMN_FARMLANDS: CompressedTexture2D = preload("res://assets/resources/world/landscape/autumn/farmlands.png")
const WINTER_FARMLANDS: CompressedTexture2D = preload("res://assets/resources/world/landscape/winter/farmlands.png")
const SPRING_WATERINGS: CompressedTexture2D = preload("res://assets/resources/world/landscape/spring/waterings.png")
const SUMMER_WATERINGS: CompressedTexture2D = preload("res://assets/resources/world/landscape/summer/waterings.png")
const AUTUMN_WATERINGS: CompressedTexture2D = preload("res://assets/resources/world/landscape/autumn/waterings.png")
const WINTER_WATERINGS: CompressedTexture2D = preload("res://assets/resources/world/landscape/winter/waterings.png")

const HOUSE_SPRING: CompressedTexture2D = preload("res://assets/resources/buildings/house/spring.png")
const HOUSE_SUMMER: CompressedTexture2D = preload("res://assets/resources/buildings/house/summer.png")
const HOUSE_AUTUMN: CompressedTexture2D = preload("res://assets/resources/buildings/house/autumn.png")
const HOUSE_WINTER: CompressedTexture2D = preload("res://assets/resources/buildings/house/winter.png")

const STORAGE_SPRING: CompressedTexture2D = preload("res://assets/resources/buildings/storage/spring.png")
const STORAGE_SUMMER: CompressedTexture2D = preload("res://assets/resources/buildings/storage/summer.png")
const STORAGE_AUTUMN: CompressedTexture2D = preload("res://assets/resources/buildings/storage/autumn.png")
const STORAGE_WINTER: CompressedTexture2D = preload("res://assets/resources/buildings/storage/winter.png")

const MAILBOX_SPRING: CompressedTexture2D = preload("res://assets/resources/buildings/mailbox/spring.png")
const MAILBOX_SUMMER: CompressedTexture2D = preload("res://assets/resources/buildings/mailbox/summer.png")
const MAILBOX_AUTUMN: CompressedTexture2D = preload("res://assets/resources/buildings/mailbox/autumn.png")
const MAILBOX_WINTER: CompressedTexture2D = preload("res://assets/resources/buildings/mailbox/winter.png")

const CYCLE_GRADIENT: GradientTexture1D = preload("res://assets/resources/world/gradients/summer.tres")


func _ready() -> void:
	if is_instance_valid(shadow):
		shadow.self_modulate = WeatherManager.CANVAS_COLOR

	# if is_instance_valid(cycle):
	# 	update_sample()

	if is_instance_valid(tilemap) && is_instance_valid(nature):
		update_season()

	if is_instance_valid(canvas):
		clouds_spawner = Timer.new()
		clouds_spawner.wait_time = WeatherManager.WAIT_TIME[0] * 10
		clouds_spawner.autostart = true
		clouds_spawner.timeout.connect(clouds_spawn)
		canvas.add_child(clouds_spawner)

		clouds_updater = Timer.new()
		clouds_updater.autostart = true
		clouds_updater.wait_time = 1.0
		clouds_updater.timeout.connect(clouds_update)
		canvas.add_child(clouds_updater)

		canvas.self_modulate = WeatherManager.CANVAS_COLOR
	GameData.settings_load()
	UIManager.blackout.blackout(false)


func update_sample() -> void:
	var time: Dictionary = Time.get_time_dict_from_system()

	if time.hour >= 5 && time.hour <= 7:
		cycle.color = CYCLE_GRADIENT.gradient.sample(0.5)

	if time.hour >= 8 && time.hour <= 11:
		cycle.color = CYCLE_GRADIENT.gradient.sample(0.65)

	if time.hour >= 12 && time.hour <= 15:
		cycle.color = CYCLE_GRADIENT.gradient.sample(1.0)

	if time.hour >= 16 && time.hour <= 19:
		cycle.color = CYCLE_GRADIENT.gradient.sample(0.55)

	if time.hour >= 20 && time.hour <= 22:
		cycle.color = CYCLE_GRADIENT.gradient.sample(0.40)

	if time.hour >= 23 || (time.hour >= 0 && time.hour <= 4):
		cycle.color = CYCLE_GRADIENT.gradient.sample(0.0)


func update_season() -> void:
	var date: Dictionary = Time.get_date_dict_from_system()
	if date.month >= 3 && date.month <= 5:
		tilemap.tile_set.get_source(0).texture = SPRING_GROUND
		tilemap.tile_set.get_source(1).texture = SPRING_ROADS
		tilemap.tile_set.get_source(2).texture = SPRING_FARMLANDS
		tilemap.tile_set.get_source(3).texture = SPRING_WATERINGS
		update_buildings(WorldCycle.Season.SPRING)
		update_natures(WorldCycle.Season.SPRING)

	if date.month >= 6 && date.month <= 8:
		tilemap.tile_set.get_source(0).texture = SUMMER_GROUND
		tilemap.tile_set.get_source(1).texture = SUMMER_ROADS
		tilemap.tile_set.get_source(2).texture = SUMMER_FARMLANDS
		tilemap.tile_set.get_source(3).texture = SUMMER_WATERINGS
		update_buildings(WorldCycle.Season.SUMMER)
		update_natures(WorldCycle.Season.SUMMER)

	if date.month >= 9 && date.month <= 11:
		tilemap.tile_set.get_source(0).texture = AUTUMN_GROUND
		tilemap.tile_set.get_source(1).texture = AUTUMN_ROADS
		tilemap.tile_set.get_source(2).texture = AUTUMN_FARMLANDS
		tilemap.tile_set.get_source(3).texture = AUTUMN_WATERINGS
		update_buildings(WorldCycle.Season.AUTUMN)
		update_natures(WorldCycle.Season.AUTUMN)

	if date.month >= 12 && date.month <= 2:
		tilemap.tile_set.get_source(0).texture = WINTER_GROUND
		tilemap.tile_set.get_source(1).texture = WINTER_ROADS
		tilemap.tile_set.get_source(2).texture = WINTER_FARMLANDS
		tilemap.tile_set.get_source(3).texture = WINTER_WATERINGS
		update_buildings(WorldCycle.Season.WINTER)
		update_natures(WorldCycle.Season.WINTER)

		var farmlands: Array[Vector2i] = tilemap.get_used_cells(2)
		var waterings: Array[Vector2i] = tilemap.get_used_cells(3)
		if !farmlands.is_empty():
			for f in farmlands:
				tilemap.erase_cell(2, f)

		if !waterings.is_empty():
			for w in farmlands:
				tilemap.erase_cell(3, w)


func update_buildings(season: WorldCycle.Season) -> void:
	if !is_instance_valid(house) || !is_instance_valid(mailbox) || !is_instance_valid(storage):
		return

	match season:
		0:
			house.texture = HOUSE_SPRING
			storage.texture = STORAGE_SPRING
			mailbox.texture = MAILBOX_SPRING
		1:
			house.texture = HOUSE_SUMMER
			storage.texture = STORAGE_SUMMER
			mailbox.texture = MAILBOX_SUMMER
		2:
			house.texture = HOUSE_AUTUMN
			storage.texture = STORAGE_AUTUMN
			mailbox.texture = MAILBOX_AUTUMN
		3:
			house.texture = HOUSE_WINTER
			storage.texture = STORAGE_WINTER
			mailbox.texture = MAILBOX_WINTER


func update_natures(season: WorldCycle.Season) -> void:
	if nature.get_children().is_empty():
		return

	for i in nature.get_children():
		i.update(season)


func clouds_update() -> void:
	if clouds.is_empty():
		return

	for cloud in clouds:
		if clouds[cloud]["lifetime"] - 1 > 1:
			clouds[cloud]["lifetime"] -= 1
		else:
			clouds[cloud]["node"].queue_free()
			clouds.erase(cloud)


func clouds_spawn() -> void:
	clouds_spawner.wait_time = randf_range(WeatherManager.WAIT_TIME[0], WeatherManager.WAIT_TIME[1]) * 10

	var sprite: Sprite2D = Sprite2D.new()
	var texture: CompressedTexture2D = WeatherManager.CLOUDS_TEXTURES[randi() % WeatherManager.CLOUDS_TEXTURES.size()]
	var current_position: Vector2 = tilemap.map_to_local(
		Vector2(
			randi_range(CLOUDS_COORDS[0].x, CLOUDS_COORDS[1].x), randi_range(CLOUDS_COORDS[0].y, CLOUDS_COORDS[1].y)
		)
	)

	sprite.texture = texture
	sprite.set_position(current_position)
	sprite.set_script(WeatherManager.CLOUDS_SCRIPT)

	canvas.add_child(sprite, true)
	clouds[sprite.name] = {}
	clouds[sprite.name]["node"] = sprite
	clouds[sprite.name]["lifetime"] = randi_range(8, 20)
