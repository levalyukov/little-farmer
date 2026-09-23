extends Node2D

const ATLAS: CompressedTexture2D = preload("res://assets/resources/farming/crops.png")
const SIZE: Vector2i = Vector2i(16, 32)
const MORTALITY: int = 100

#* ------------------------------------------------------------------------ *#
# *	caption:String			<- Название культуры.						   * #
# *	season:Array[int]		<- Позволяет высаживать в заданные сезоны.	   * #
# *	growth:float			<- Скорость роста культуры.					   * #
# *	level:int				<- Максимальный уровень роста.				   * #
# *	coords:Vector2i			<- Координаты на атласе.					   * #
# *	item_id:int				<- ID урожая после сбора.					   * #
# *	spoilage_id:int			<- ID испорченого урожая.					   * #
# *	item_value:Vector2i		<- Кол-во предметов при сборе урожая.		   * #
#* ------------------------------------------------------------------------ *#

var crops: Dictionary = {
	#* ------------------- *#
	# * Весенние культуры * #
	#* ------------------- *#
	1:
	{
		"caption": "crops.carrot",
		"season": [0],
		"growth": 1.0,
		"level": 5,
		"coords": Vector2i(0, 0),
		"item_id": 5,
		"spoilage_id": 43,
		"item_value": Vector2i(1,1),
	},
	2:
	{
		"caption": "crops.potato",
		"season": [0],
		"growth": 100.0,
		"level": 6,
		"coords": Vector2i(0, 32),
		"item_id": 29,
		"spoilage_id": 44,
		"item_value": Vector2i(1,3),
	},
	3:
	{
		"caption": "crops.radish",
		"season": [0],
		"growth": 60.0,
		"level": 4,
		"coords": Vector2i(0, 64),
		"item_id": 30,
		"spoilage_id": 45,
		"item_value": Vector2i(1,1),
	},
	4:
	{
		"caption": "crops.cabbage",
		"season": [0],
		"growth": 180.0,
		"level": 4,
		"coords": Vector2i(0, 96),
		"item_id": 31,
		"spoilage_id": 46,
		"item_value": Vector2i(1,1),
	},
	5:
	{
		"caption": "crops.onion",
		"season": [0],
		"growth": 80.0,
		"level": 5,
		"coords": Vector2(0, 128),
		"item_id": 32,
		"spoilage_id": 47,
		"item_value": Vector2i(1,1),
	},
	#* ------------------- *#
	# *  Летние культуры  * #
	#* ------------------- *#
	6:
	{
		"caption": "crops.cucumber",
		"season": [1],
		"growth": 100.0,
		"level": 6,
		"coords": Vector2i(112, 0),
		"item_id": 33,
		"spoilage_id": 48,
		"item_value": Vector2i(1,2),
	},
	7:
	{
		"caption": "crops.tomato",
		"season": [1],
		"growth": 150.0,
		"level": 6,
		"coords": Vector2i(112, 32),
		"item_id": 34,
		"spoilage_id": 49,
		"item_value": Vector2i(1,3),
	},
	8:
	{
		"caption": "crops.eggplant",
		"season": [1],
		"growth": 175.0,
		"level": 4,
		"coords": Vector2i(112, 64),
		"item_id": 35,
		"spoilage_id": 50,
		"item_value": Vector2i(1,2),
	},
	9:
	{
		"caption": "crops.pepper",
		"season": [1],
		"growth": 100.0,
		"level": 5,
		"coords": Vector2i(112, 96),
		"item_id": 36,
		"spoilage_id": 51,
		"item_value": Vector2i(1,3),
	},
	10:
	{
		"caption": "crops.corn",
		"season": [1],
		"growth": 225.0,
		"level": 6,
		"coords": Vector2i(112, 128),
		"item_id": 37,
		"spoilage_id": 52,
		"item_value": Vector2i(1,4),
	},
	#* ------------------ *#
	# * Осенние культуры * #
	#* ------------------ *#
	11:
	{
		"caption": "crops.parsnips",
		"season": [2],
		"growth": 65.0,
		"level": 4,
		"coords": Vector2i(244, 0),
		"item_id": 38,
		"spoilage_id": 53,
		"item_value": Vector2i(1,1),
	},
	12:
	{
		"caption": "crops.garlic",
		"season": [2],
		"growth": 75.0,
		"level": 5,
		"coords": Vector2i(224, 32),
		"item_id": 39,
		"spoilage_id": 54,
		"item_value": Vector2i(1,2),
	},
	13:
	{
		"caption": "crops.beet",
		"season": [2],
		"growth": 65.2,
		"level": 6,
		"coords": Vector2i(224, 64),
		"item_id": 40,
		"spoilage_id": 55,
		"item_value": Vector2i(1,2),
	},
	14:
	{
		"caption": "crops.turnip",
		"season": [2],
		"growth": 50.5,
		"level": 4,
		"coords": Vector2i(224, 96),
		"item_id": 41,
		"spoilage_id": 56,
		"item_value": Vector2i(1,1),
	},
	15:
	{
		"caption": "crops.bean",
		"season": [2],
		"growth": 80.6,
		"level": 4,
		"coords": Vector2i(224, 128),
		"item_id": 42,
		"spoilage_id": 57,
		"item_value": Vector2i(1,2),
	},
}


func _ready() -> void:
	crops.make_read_only()

func get_crop(id:int) -> Dictionary:
	var data:Dictionary = {}
	
	if self.crops.has(id):
		data["id"] = id
		data.merge(crops[id])

	return data
		