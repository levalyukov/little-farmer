extends Node

class_name Blueprints
var content:Dictionary = {
	"terrains": {
		1: {
			"caption" = "Тропинки",
			"description" = "",
			"icon" = null,#preload(""),
			"config" = {
				"terrain_set" = 1,
				"required_layer" = 0,
			}
		},
		2: {
			"caption" = "Вода",
			"description" = "",
			"icon" = null,#preload(""),
			"config" = {
				"terrain_set" = 1,
				"required_layer" = 0,
			}
		}
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
