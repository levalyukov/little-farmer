extends Node

class_name BlueprintManager
@onready var main = str(get_tree().root.get_child(2).name)
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
var content:Dictionary = {
	"terrains": {
		1: {
			"caption" = "blueprints.path.caption",
			"description" = 'blueprints.path.description',
			"icon" = load("res://assets/resources/ui/interactive/construct/roads.png"),
			"config" = {
				"terrain" = [0],
				"required_layer" = [1],
				"blocking_layer" = [1,2,3,5],
			},

			"trade_info" = {
				"caption" = "blueprints.path_blueprint.caption",
				"description" = 'blueprints.path_blueprint.description',
				"price" = 100
			}
		},
		2: {
			"caption" = "blueprints.water_body.caption",
			"description" = 'blueprints.water_body.description',
			"icon" = load("res://assets/resources/ui/interactive/construct/water.png"),
			"config" = {
				"terrain" = [3,4],
				"required_layer" = [3,5],
				"blocking_layer" = [1,2,3,9],
			},

			"trade_info" = {
				"caption" = "blueprints.water_body_blueprints.caption",
				"description" = "blueprints.water_body_blueprints.description",
				"price" = 500
			}
		},
	},
	
	"nodes": {
		1: {
			"caption" = "blueprints.wooden_sign.caption",
			"description" = "blueprints.wooden_sign.description",
			"icon" = load("res://assets/resources/buildings/sign/summer/object_0.png"),
			"config" = {
				"name" = "sign",
				"node" = load("res://assets/nodes/buildings/sign.tscn"),
				"shadow" = load("res://assets/nodes/buildings/sign_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					1:{"amount": 1},
					2:{"amount": 5},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.wooden_sign_blueprint.caption",
				"description" = "blueprints.wooden_sign_blueprint.description",
				"price" = 250
			}
		},
		2: {
			"caption" = "blueprints.composter.caption",
			"description" = "blueprints.composter.description",
			"icon" = load("res://assets/resources/buildings/composter/idle_0.png"),
			"config" = {
				"name" = "composter",
				"node" = load("res://assets/nodes/buildings/composter.tscn"),
				"shadow" = load("res://assets/nodes/buildings/composter_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					2:{"amount": 25},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.composter_blueprint.caption",
				"description" = "blueprints.composter_blueprint.description",
				"price" = 750
			}
		},
		3: {
			"caption" = "blueprints.well.caption",
			"description" = "blueprints.well.description",
			"icon" = load("res://assets/resources/buildings/well/icon.png"),
			"config" = {
				"name" = "well",
				"node" = load("res://assets/nodes/buildings/well/well.tscn"),
				"shadow" = load("res://assets/nodes/buildings/well/well_shadow.tscn"),
				"area" = Vector2i(2,2),
				"resources" = {
					3:{"amount": 50},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.well_blueprint.caption",
				"description" = "blueprints.well_blueprint.description",
				"price" = 1000
			}
		},
		4: {
			"caption" = "blueprints.barn.caption",
			"description" = "blueprints.barn.description",
			"icon" = load("res://assets/resources/buildings/stall/level_1/summer/object_0.png"),
			"config" = {
				"name" = "animal_stall",
				"node" = load("res://assets/nodes/buildings/stall/animal_stall.tscn"),
				"shadow" = load("res://assets/nodes/buildings/stall/animal_stall_shadow.tscn"),
				"area" = Vector2i(3,2),
				"resources" = {
					1:{"amount": 100},
					3:{"amount": 25},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.barn_blueprint.caption",
				"description" = "blueprints.barn_blueprint.description",
				"price" = 5000
			}
		},
		5: {
			"caption" = "blueprints.silo.caption",
			"description" = "blueprints.silo.description",
			"icon" = load("res://assets/resources/buildings/silo/level_1/summer/object_0.png"),
			"config" = {
				"name" = "silo",
				"node" = load("res://assets/nodes/buildings/silo/silo.tscn"),
				"shadow" = load("res://assets/nodes/buildings/silo/silo_shadow.tscn"),
				"area" = Vector2i(2,2),
				"resources" = {
					1:{"amount": 100},
					3:{"amount": 25},
					7:{"amount": 25},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.silo_blueprint.caption",
				"description" = "blueprints.silo_blueprint.description",
				"price" = 2500
			}
		},
		6: {
			"caption" = "blueprints.greenhouse.caption",
			"description" = "blueprints.greenhouse.description",
			"icon" = load("res://assets/resources/buildings/greenhouse/level_1/summer/object_0.png"),
			"config" = {
				"name" = "greenhouse",
				"node" = load("res://assets/nodes/buildings/greenhouse/greenhouse.tscn"),
				"shadow" = load("res://assets/nodes/buildings/greenhouse/greenhouse_shadow.tscn"),
				"area" = Vector2i(3,3),
				"resources" = {
					11:{"amount": 25}
				}
			},

			"trade_info" = {
				"caption" = "blueprints.greenhouse_blueprint.caption",
				"description" = "blueprints.greenhouse_blueprint.description",
				"price" = 20000
			}
		},
		7: {
			"caption" = "blueprints.lantern_post.caption",
			"description" = "blueprints.lantern_post.description",
			"icon" = load("res://assets/resources/buildings/lamp_post/object_1.png"),
			"config" = {
				"name" = "lamp_post",
				"node" = load("res://assets/nodes/buildings/lamp_post.tscn"),
				"shadow" = load("res://assets/nodes/buildings/lamp_post_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					1:{"amount": 1},
					2:{"amount": 5},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.lantern_post_blueprints.caption",
				"description" = "blueprints.lantern_post_blueprints.description",
				"price" = 1000
			}
		},
		8: {
			"caption" = "blueprints.stone_path.caption",
			"description" = "blueprints.stone_path.description",
			"icon" = load("res://assets/resources/buildings/path_of_large_stones/object_0.png"),
			"config" = {
				"name" = "lamp_post",
				"node" = load("res://assets/nodes/buildings/path_of_large_stones.tscn"),
				"shadow" = load("res://assets/nodes/buildings/path_of_large_stones_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					4:{"amount": 5},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.stone_path_blueprint.caption",
				"description" = "blueprints.stone_path_blueprint.description",
				"price" = 500
			}
		},
		9: {
			"caption" = "blueprints.stone_forge.caption",
			"description" = "blueprints.stone_forge.description",
			"icon" = load("res://assets/resources/buildings/stone_oven/object_0.png"),
			"config" = {
				"name" = "forge",
				"node" = load("res://assets/nodes/buildings/forge.tscn"),
				"shadow" = load("res://assets/nodes/buildings/forge_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					3:{"amount": 50},
					5:{"amount": 10},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.stone_forge_blueprint.caption",
				"description" = "blueprints.stone_forge_blueprint.description",
				"price" = 2000
			}
		},
		10: {
			"caption" = "blueprints.radio.caption",
			"description" = "blueprints.radio.description",
			"icon" = load("res://assets/resources/buildings/radio/obj_0.png"),
			"config" = {
				"name" = "radio",
				"node" = load("res://assets/nodes/buildings/radio.tscn"),
				"shadow" = load("res://assets/nodes/buildings/radio_shadow.tscn"),
				"area" = Vector2i(1,1),
				"onlyInstance" = true,
			},

			"trade_info" = {
				"caption" = "blueprints.radio_blueprint.caption",
				"description" = "blueprints.radio_blueprint.description",
				"price" = 7500
			}
		},
		11: {
			"caption" = "blueprints.sawbench.caption",
			"description" = "blueprints.sawbench.description",
			"icon" = load("res://assets/resources/buildings/sawmill/obj_0.png"),
			"config" = {
				"name" = "sawmill",
				"node" = load("res://assets/nodes/buildings/sawmill.tscn"),
				"shadow" = load("res://assets/nodes/buildings/sawmill_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					1:{"amount": 5},
					10:{"amount": 2},
				}
			},

			"trade_info" = {
				"caption" = "blueprints.sawbench_blueprint.caption",
				"description" = "blueprints.sawbench_blueprint.description",
				"price" = 1500
			}
		},
		#	6: {
		#		"caption" = "Новогодняя ёлка",
		#		"description" = "С Новым Годом!",
		#		"icon" = load("res://assets/resources/buildings/christmass_tree/icon.png"),
		#		"config" = {
		#			"name" = "christmas_tree",
		#			"node" = load("res://assets/nodes/buildings/christmas_tree/christmas_tree.tscn"),
		#			"shadow" = load("res://assets/nodes/buildings/christmas_tree/christmas_tree_shadow.tscn"),
		#			"area" = Vector2i(1,1),
		#			"resources" = {}
		#		}
		#	},
	},
	
	"upgrades": {}
}
