extends TileMap

enum Layers { GROUND, ROAD, NATURE, COAST, AQUATIC, WATER, FARMLAND, WATERING, CROPS, BUILDING, BORDERS }
enum Terrains { ROADS, FARMING, WATERING, COAST, WATER }
enum SourcesAtlas { GROUND, ROADS, FARMLANDS, WATERINGS_FARMLANDS, COASTS, WATER }

const NODE_COLLISION: Vector2i = Vector2i(0, 3)
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


func update_atlas(season: WorldCycle.Season) -> void:
	if !ATLAS.has(season):
		printerr("Error while get atlas from the tilemap.")
		return

	tile_set.get_source(0).texture = (
		ATLAS[season][0] if ATLAS[season].has(0) && ATLAS[season][0] is CompressedTexture2D else null
	)

	tile_set.get_source(1).texture = (
		ATLAS[season][1] if ATLAS[season].has(1) && ATLAS[season][1] is CompressedTexture2D else null
	)

	tile_set.get_source(2).texture = (
		ATLAS[season][2] if ATLAS[season].has(2) && ATLAS[season][2] is CompressedTexture2D else null
	)

	tile_set.get_source(3).texture = (
		ATLAS[season][3] if ATLAS[season].has(3) && ATLAS[season][3] is CompressedTexture2D else null
	)

	tile_set.get_source(4).texture = (
		ATLAS[season][4] if ATLAS[season].has(4) && ATLAS[season][4] is CompressedTexture2D else null
	)

	tile_set.get_source(5).texture = (
		ATLAS[season][5] if ATLAS[season].has(5) && ATLAS[season][5] is CompressedTexture2D else null
	)
