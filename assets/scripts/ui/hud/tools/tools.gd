extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

const max_grid_dimensions:int = 32

var water_can_max:int = 100
var water_can:int = 100
# farming
var hoe:int = 1 # for plowing the cells
var watering_can:int = 1 # for watering the cells
var sickle:int = 1 # for harvesting
var planting:int = 1 

# destroy mode
var axe:int = 1 # for trees
var pickaxe:int = 1 # for rocks and boulders 
var destroy:int = 1

var features:Dictionary = {
	"planting": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
	"hoe": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
	"sickle": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
	"watering_can": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
	"axe": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
	"pickaxe": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
	"destroy": {
		1: {
			"grid_dimensions" = Vector2i(1,1)
		},
	},
}
