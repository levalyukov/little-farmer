extends Node

class_name Blueprints
@onready var main = str(get_tree().root.get_child(1).name)
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
var content:Dictionary = {
	"terrains": {
		1: {
			"caption" = "Тропинки",
			"description" = "",
			"icon" = null,#preload(""),
			"config" = {
				"terrain" = [0],
				"required_layer" = [1],
				"blocking_layer" = [1,2,3,5],
			}
		},
		2: {
			"caption" = "Вода",
			"description" = "",
			"icon" = null,#preload(""),
			"config" = {
				"terrain" = [3,4],
				"required_layer" = [3,5],
				"blocking_layer" = [1,2,3,9],
			}
		},
	},
	
	"nodes": {
		1: {
			"caption" = "Деревянный знак",
			"description" = "Деревянный знак...",
			"icon" = preload("res://assets/resources/buildings/sign/summer/object_0.png"),
			"config" = {
				"name" = "sign",
				"node" = preload("res://assets/nodes/buildings/sign.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/sign_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					1:{"amount":25}
				}
			}
		},
		2: {
			"caption" = "Колодец",
			"description" = "Колодец...",
			"icon" = preload("res://assets/resources/buildings/well/icon.png"),
			"config" = {
				"name" = "well",
				"node" = preload("res://assets/nodes/buildings/well/well.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/well/well_shadow.tscn"),
				"area" = Vector2i(2,2),
				"resources" = {
					1:{"amount":25}
				}
			}
		},
		3: {
			"caption" = "Хлев",
			"description" = "Хлев...",
			"icon" = preload("res://assets/resources/buildings/stall/level_1/summer/object_0.png"),
			"config" = {
				"name" = "animal_stall",
				"node" = preload("res://assets/nodes/buildings/stall/animal_stall.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/stall/animal_stall_shadow.tscn"),
				"area" = Vector2i(3,2),
				"resources" = {
					1:{"amount":25}
				}
			}
		},
		4: {
			"caption" = "Силосная башня",
			"description" = "Силосная башня...",
			"icon" = preload("res://assets/resources/buildings/silo/level_1/summer/object_0.png"),
			"config" = {
				"name" = "silo",
				"node" = preload("res://assets/nodes/buildings/silo/silo.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/silo/silo_shadow.tscn"),
				"area" = Vector2i(2,2),
				"resources" = {
					1:{"amount":25}
				}
			}
		},
		5: {
			"caption" = "Новогодняя ёлка",
			"description" = "С Новым Годом!",
			"icon" = preload("res://assets/resources/buildings/christmass_tree/icon.png"),
			"config" = {
				"name" = "christmas_tree",
				"node" = preload("res://assets/nodes/buildings/christmas_tree/christmas_tree.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/christmas_tree/christmas_tree_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					
				}
			}
		},
	},
	
	"upgrades": {}
}
