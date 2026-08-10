extends TileMap

# =============================================================================================
# (tilemap.gd)
# =============================================================================================
# Менеджер тайловой карты
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Обновление текстур слоев тайловой карты в зависимости от времени года.
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - update_atlas()
#
# ЗАВИСИМОСТИ:
# - building_manager -
# - nature_manager -
# - shadow_manager -
#
# =============================================================================================

#@export var build_manager: BuildManager

const LAYERS: Dictionary = {
	GROUND = 0,
	ROAD = 1,
	NATURE = 2,
	COAST = 3,
	AQUATIC = 4,
	WATER = 5,
	FARMLAND = 6,
	WATERING = 7,
	CROPS = 8,
	BUILDING = 9,
	GAME_BORDER = 10
}

const TERRAINS: Dictionary = {ROADS = 0, FARMING = 1, WATERING = 2, COAST = 3, WATER = 4}

const ATLAS: Dictionary = {
	"spring":
	{
		0: preload("res://assets/resources/world/landscape/spring/ground.png"),
		1: preload("res://assets/resources/world/landscape/spring/roads.png"),
		2: preload("res://assets/resources/world/landscape/spring/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/spring/waterings.png"),
		4: preload("res://assets/resources/world/landscape/spring/coasts.png"),
		5: preload("res://assets/resources/world/landscape/spring/water.png")
	},
	"summer":
	{
		0: preload("res://assets/resources/world/landscape/summer/ground.png"),
		1: preload("res://assets/resources/world/landscape/summer/roads.png"),
		2: preload("res://assets/resources/world/landscape/summer/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/summer/waterings.png"),
		4: preload("res://assets/resources/world/landscape/summer/coasts.png"),
		5: preload("res://assets/resources/world/landscape/summer/water.png")
	},
	"autumn":
	{
		0: preload("res://assets/resources/world/landscape/autumn/ground.png"),
		1: preload("res://assets/resources/world/landscape/autumn/roads.png"),
		2: preload("res://assets/resources/world/landscape/autumn/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/autumn/waterings.png"),
		4: preload("res://assets/resources/world/landscape/autumn/coasts.png"),
		5: preload("res://assets/resources/world/landscape/autumn/water.png")
	},
	"winter":
	{
		0: preload("res://assets/resources/world/landscape/winter/ground.png"),
		1: preload("res://assets/resources/world/landscape/winter/roads.png"),
		2: preload("res://assets/resources/world/landscape/winter/farmlands.png"),
		3: preload("res://assets/resources/world/landscape/winter/waterings.png"),
		4: preload("res://assets/resources/world/landscape/winter/coasts.png"),
		5: preload("res://assets/resources/world/landscape/winter/water.png")
	}
}


func update_atlas(season: String) -> void:
	if ATLAS.has(season):
		if (
			ATLAS[season].has(0)
			&& ATLAS[season].has(1)
			&& ATLAS[season].has(2)
			&& ATLAS[season].has(3)
			&& ATLAS[season].has(4)
			&& ATLAS[season].has(5)
			&& ATLAS[season][0] is CompressedTexture2D
			&& ATLAS[season][1] is CompressedTexture2D
			&& ATLAS[season][2] is CompressedTexture2D
			&& ATLAS[season][3] is CompressedTexture2D
			&& ATLAS[season][4] is CompressedTexture2D
			&& ATLAS[season][5] is CompressedTexture2D
		):
			tile_set.get_source(0).texture = ATLAS[season][0]
			tile_set.get_source(1).texture = ATLAS[season][1]
			tile_set.get_source(2).texture = ATLAS[season][2]
			tile_set.get_source(3).texture = ATLAS[season][3]
			tile_set.get_source(4).texture = ATLAS[season][4]
			tile_set.get_source(5).texture = ATLAS[season][5]

			# if building_manager && !building_manager.get_children().is_empty():
			# 	for node in building_manager.get_children():
			# 		if node.has_method("get_data"):
			# 			if 'level' in node:
			# 				if node.object.has(node.level)\
			# 				&& node.object[node.level].has("seasons")\
			# 				&& node.object[node.level]["seasons"].has(season)\
			# 				&& node.object[node.level]["seasons"][season].has("default"):
			# 					node.update()
			# 			else:
			# 				if node.has_method("update")\
			# 				&& node.object.has("seasons")\
			# 				&& node.object["seasons"].has(season)\
			# 				&& node.object["seasons"][season].has("default"):
			# 					node.update()
			# 		else:
			# 			if node.has_method("update")\
			# 			&& node.TEXTURES.has("seasons")\
			# 			&& node.TEXTURES["seasons"].has(season)\
			# 			&& node.TEXTURES["seasons"][season].has("default"):
			# 				node.update()

			# if nature_manager && nature_manager.get_children() != []:
			# 	nature_manager.clear_all_arrays()
			# 	nature_manager._set_new_sprites()
			# 	for nature in nature_manager.get_children():
			# 		if nature.has_method('change_texture'):
			# 			match Utils.remove_suffix(nature.name):
			# 				"tree":
			# 					nature.change_texture(nature_manager._trees[nature.index])
			# 				"stone":
			# 					nature.change_texture(nature_manager._stones[nature.index])
			# 				"weed":
			# 					nature.change_texture(nature_manager._weeds[nature.index])

			# if shadow_manager && shadow_manager.get_children() != []:
			# 	for shadow in shadow_manager.get_children():
			# 		if shadow.has_method("is_nature_shadow"):
			# 			match shadow.type:
			# 				"tree":
			# 					shadow.change_sprite(nature_manager._trees_shadow[shadow.index])
			# 				"stone":
			# 					shadow.change_sprite(nature_manager._stones_shadow[shadow.index])
			# 				"weed":
			# 					shadow.change_sprite(nature_manager._weeds_shadow[shadow.index])
