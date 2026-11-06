extends TileMap

enum Layers { GROUND, ROAD, NATURE, COAST, AQUATIC, WATER, FARMLAND, WATERING, CROPS, BUILDING, BORDERS, STATIC_NODES }
enum Terrains { ROADS, FARMING, WATERING, COAST, WATER }
enum SourcesAtlas { GROUND, ROADS, FARMLANDS, WATERINGS_FARMLANDS, COASTS, WATER, DEV }

const NODE_COLLISION: Vector2i = Vector2i(1, 0)
const PLANT_COLLISION: Vector2i = Vector2i(2, 0)
const NATURE_COLLISION:Vector2i = Vector2i(0,1)
const ATLAS: Dictionary = {
	WorldCycle.Season.SPRING:
	{
		0: preload("res://assets/resources/world/landscape/spring/ground.png"),
		1: preload("res://assets/resources/world/landscape/spring/roads.png"),
		2: preload("res://assets/resources/world/landscape/spring/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/spring/waterings.png"),
		4: preload("res://assets/resources/world/landscape/spring/coasts.png"),
		5: preload("res://assets/resources/world/landscape/spring/water.png")
	},
	WorldCycle.Season.SUMMER:
	{
		0: preload("res://assets/resources/world/landscape/summer/ground.png"),
		1: preload("res://assets/resources/world/landscape/summer/roads.png"),
		2: preload("res://assets/resources/world/landscape/summer/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/summer/waterings.png"),
		4: preload("res://assets/resources/world/landscape/summer/coasts.png"),
		5: preload("res://assets/resources/world/landscape/summer/water.png")
	},
	WorldCycle.Season.AUTUMN:
	{
		0: preload("res://assets/resources/world/landscape/autumn/ground.png"),
		1: preload("res://assets/resources/world/landscape/autumn/roads.png"),
		2: preload("res://assets/resources/world/landscape/autumn/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/autumn/waterings.png"),
		4: preload("res://assets/resources/world/landscape/autumn/coasts.png"),
		5: preload("res://assets/resources/world/landscape/autumn/water.png")
	},
	WorldCycle.Season.WINTER:
	{
		0: preload("res://assets/resources/world/landscape/winter/ground.png"),
		1: preload("res://assets/resources/world/landscape/winter/roads.png"),
		2: preload("res://assets/resources/world/landscape/winter/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/winter/waterings.png"),
		4: preload("res://assets/resources/world/landscape/winter/coasts.png"),
		5: preload("res://assets/resources/world/landscape/winter/water.png")
	}
}


func _ready() -> void:
	var _hide: Color = Color(0, 0, 0, 0)
	self.set_layer_modulate(Layers.CROPS, _hide)
	self.set_layer_modulate(Layers.NATURE, _hide)
	self.set_layer_modulate(Layers.BUILDING, _hide)
	self.set_layer_modulate(Layers.BORDERS, _hide)
	self.set_layer_modulate(Layers.STATIC_NODES, _hide)


func update_atlas(season: WorldCycle.Season) -> void:
	if !ATLAS.has(season):
		printerr("Error while get atlas from the tilemap.")
		return

	if (
		ATLAS[season].has(0)
		&& ATLAS[season][0] is CompressedTexture2D
		&& ATLAS[season].has(1)
		&& ATLAS[season][1] is CompressedTexture2D
		&& ATLAS[season].has(1)
		&& ATLAS[season][2] is CompressedTexture2D
		&& ATLAS[season].has(1)
		&& ATLAS[season][3] is CompressedTexture2D
		&& ATLAS[season].has(1)
		&& ATLAS[season][4] is CompressedTexture2D
		&& ATLAS[season].has(1)
		&& ATLAS[season][1] is CompressedTexture2D
	):
		tile_set.get_source(0).texture = ATLAS[season][0]
		tile_set.get_source(1).texture = ATLAS[season][1]
		tile_set.get_source(2).texture = ATLAS[season][2]
		tile_set.get_source(3).texture = ATLAS[season][3]
		tile_set.get_source(4).texture = ATLAS[season][4]
		tile_set.get_source(5).texture = ATLAS[season][5]
