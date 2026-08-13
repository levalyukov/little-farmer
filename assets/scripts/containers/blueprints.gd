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

var blueprints:Dictionary = \
{
	BlueprintsType.BUILDINGS:
	{
		0:
		{
			"title": tr("blueprint.well.title"),
			"description": tr("blueprint.well.description"),
			"icon": preload("res://assets/resources/buildings/well/icon.png"),
			"node": preload("res://assets/nodes/buildings/well/well.tscn"),
			"time": 753.00,
			"size": Vector2i(2,2),
			"resources":
			{
				Items.ItemsType.MATERIALS:
				{
					1:{"amount": 100},
					2:{"amount": 100},
					3:{"amount": 100}
				}
			}
		},

		1:
		{
			"title": tr("blueprint.animal_stall.title"),
			"description": tr("blueprint.animal_stall.description"),
			"icon": preload("res://assets/resources/buildings/stall/level_1/summer/object_0.png"),
			"node": preload("res://assets/nodes/buildings/stall/animal_stall.tscn"),
			"time": 120.00,
			"size": Vector2i(3,2),
			"resources":
			{
					
			}
		}
	},

	BlueprintsType.TERRAINS:
	{
		0:
		{
			"title": tr("blueprint.roads.title"),
			"description": tr("blueprint.well.description"),
			"icon": preload("res://assets/resources/ui/interactive/construct/roads.png"),
			"layer": [],
			"size": Vector2i(2,2)
		},

		1:
		{
			"title": tr("blueprint.water.title"),
			"description": tr("blueprint.well.description"),
			"icon": preload("res://assets/resources/ui/interactive/construct/water.png"),
			"layer": [],
			"size": Vector2i(2,2)
		},
	}
}

enum BlueprintsType {BUILDINGS, TERRAINS}


func _ready() -> void:
	blueprints.make_read_only()


func blueprint_get(type:BlueprintsType, id:int) -> Dictionary:
	var data:Dictionary = {}

	if blueprints[type].has(id):
		data.merge(blueprints[type][id])
	
	return data