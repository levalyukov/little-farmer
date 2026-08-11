extends Node

# ===================================================================
# BlueprintsManager (blueprints.gd)
# ===================================================================
# Является главным хранилищем всех игровых чертежей: постройки,
# местности, улучшения и так далее.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Корректное обращение к главному хранилищу чертежей
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - blueprint_get(type, id) - Возвращает данные об постройке, если существует
#
# ===================================================================

const BLUEPRINTS:Dictionary = \
{
	BlueprintsType.BUILDINGS:
	{
		0:
		{
			"title": "blueprint.well.title",
			"description": "blueprint.well.description",
			"icon": preload("res://assets/resources/buildings/well/icon.png"),
			"node": preload("res://assets/nodes/buildings/well/well.tscn"),
			"time": 120.00,
			"size": Vector2i(2,2)
		},

		1:
		{
			"title": "blueprint.animal_stall.title",
			"description": "blueprint.animal_stall.description",
			"icon": preload("res://assets/resources/buildings/stall/level_1/summer/object_0.png"),
			"node": preload("res://assets/nodes/buildings/stall/animal_stall.tscn"),
			"time": 120.00,
			"size": Vector2i(2,2)
		}
	},

	BlueprintsType.TERRAINS:
	{
		0:
		{
			"title": "blueprint.roads.title",
			"description": "blueprint.well.description",
			"icon": preload("res://assets/resources/ui/interactive/construct/roads.png"),
			"layer": [],
			"size": Vector2i(2,2)
		},

		1:
		{
			"title": "blueprint.water.title",
			"description": "blueprint.well.description",
			"icon": preload("res://assets/resources/ui/interactive/construct/water.png"),
			"layer": [],
			"size": Vector2i(2,2)
		},
	}
}

enum BlueprintsType {BUILDINGS, TERRAINS}


func blueprint_get(type:BlueprintsType, id:int) -> Dictionary:
	var data:Dictionary = {}

	if BLUEPRINTS[type].has(id):
		data.merge(BLUEPRINTS[type][id])
	
	return data