class_name BlueprintManager

# ===================================================================
# BlueprintManager (blueprints.gd)
# ===================================================================
# Является главным хранилищем всех игровых чертежей: постройки,
# местности, улучшения и так далее.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Корректное обращение к главному хранилищу чертежей
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - 
#
# ===================================================================


enum BlueprintsType {BUILDINGS, TERRAINS}
const BLUEPRINTS:Dictionary = \
{
	BlueprintsType.BUILDINGS:
	{
		0:
		{
			"title": "blueprint.well.title",
			"description": "blueprint.well.description",
			"node": preload("res://assets/nodes/buildings/well/well.tscn"),
			"size": Vector2i(2,2)
		}
	},

	BlueprintsType.TERRAINS:
	{
		0:
		{
			"title": "blueprint.well.title",
			"description": "blueprint.well.description",
			"node": preload("res://assets/nodes/buildings/stall/animal_stall.tscn"),
			"size": Vector2i(2,2)
		}
	}
}

func blueprints_get(type:BlueprintsType, id:int) -> Dictionary:
	var data:Dictionary = {}

	if BLUEPRINTS[type].has(id):
		data.merge(BLUEPRINTS[type][id])
	
	return data