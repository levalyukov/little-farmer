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
				"terrain" = [2],
				"required_layer" = [1],
				"blocking_layer" = [2],
			}
		},
		2: {
			"caption" = "Вода",
			"description" = "",
			"icon" = null,#preload(""),
			"config" = {
				"terrain" = [3,4],
				"required_layer" = [1,2],
				"blocking_layer" = [1,2,3,9],
			}
		},
	},
	
	"nodes": {
		1: {
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
		}
	},
	
	"upgrades": {}
}
