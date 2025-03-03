extends Node

class_name Blueprints
@onready var main = str(get_tree().root.get_child(2).name)
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
var content:Dictionary = {
	"terrains": {
		1: {
			"caption" = tr("Тропинки"),
			"description" = "",
			"icon" = load("res://assets/resources/ui/interactive/construct/roads.png"),
			"config" = {
				"terrain" = [0],
				"required_layer" = [1],
				"blocking_layer" = [1,2,3,5],
			}
		},
		2: {
			"caption" = tr("Вода"),
			"description" = "",
			"icon" = load("res://assets/resources/ui/interactive/construct/water.png"),
			"config" = {
				"terrain" = [3,4],
				"required_layer" = [3,5],
				"blocking_layer" = [1,2,3,9],
			}
		},
	},
	
	"nodes": {
		1: {
			"caption" = tr("Деревянный знак"),
			"description" = tr("Позволяет разместить изображение любого предмета."),
			"icon" = preload("res://assets/resources/buildings/sign/summer/object_0.png"),
			"config" = {
				"name" = "sign",
				"node" = preload("res://assets/nodes/buildings/sign.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/sign_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					
				}
			}
		},
		2: {
			"caption" = tr("Компостер"),
			"description" = tr("Ящик для приготовления удобрения."),
			"icon" = preload("res://assets/resources/buildings/composter/idle_0.png"),
			"config" = {
				"name" = "composter",
				"node" = preload("res://assets/nodes/buildings/composter.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/composter_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					
				}
			}
		},
		3: {
			"caption" = tr("Колодец"),
			"description" = tr("Позволяет пополять лейку."),
			"icon" = preload("res://assets/resources/buildings/well/icon.png"),
			"config" = {
				"name" = "well",
				"node" = preload("res://assets/nodes/buildings/well/well.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/well/well_shadow.tscn"),
				"area" = Vector2i(2,2),
				"resources" = {
					
				}
			}
		},
		4: {
			"caption" = tr("Хлев"),
			"description" = tr("Место для содержания скота."),
			"icon" = preload("res://assets/resources/buildings/stall/level_1/summer/object_0.png"),
			"config" = {
				"name" = "animal_stall",
				"node" = preload("res://assets/nodes/buildings/stall/animal_stall.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/stall/animal_stall_shadow.tscn"),
				"area" = Vector2i(3,2),
				"resources" = {
					
				}
			}
		},
		5: {
			"caption" = tr("Силосная башня"),
			"description" = tr("Высокое и вместительное хранилище для кормов."),
			"icon" = preload("res://assets/resources/buildings/silo/level_1/summer/object_0.png"),
			"config" = {
				"name" = "silo",
				"node" = preload("res://assets/nodes/buildings/silo/silo.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/silo/silo_shadow.tscn"),
				"area" = Vector2i(2,2),
				"resources" = {
					
				}
			}
		},
		6: {
			"caption" = tr("Теплица"),
			"description" = tr("Тёплое помещение для разведения и выращивания растений."),
			"icon" = preload("res://assets/resources/buildings/greenhouse/level_1/summer/object_0.png"),
			"config" = {
				"name" = "greenhouse",
				"node" = preload("res://assets/nodes/buildings/greenhouse/greenhouse.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/greenhouse/greenhouse_shadow.tscn"),
				"area" = Vector2i(3,3),
				"resources" = {}
			}
		},
		7: {
			"caption" = tr("Фонарный столб"),
			"description" = tr("Источник света для вашей фермы."),
			"icon" = preload("res://assets/resources/buildings/lamp_post/object_1.png"),
			"config" = {
				"name" = "lamp_post",
				"node" = preload("res://assets/nodes/buildings/lamp_post.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/lamp_post_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					
				}
			}
		},
		8: {
			"caption" = tr("Дорожка из больших камней"),
			"description" = tr(""),
			"icon" = preload("res://assets/resources/buildings/path_of_large_stones/object_0.png"),
			"config" = {
				"name" = "lamp_post",
				"node" = preload("res://assets/nodes/buildings/path_of_large_stones.tscn"),
				"shadow" = preload("res://assets/nodes/buildings/path_of_large_stones_shadow.tscn"),
				"area" = Vector2i(1,1),
				"resources" = {
					
				}
			}
		},
		#	6: {
		#		"caption" = "Новогодняя ёлка",
		#		"description" = "С Новым Годом!",
		#		"icon" = preload("res://assets/resources/buildings/christmass_tree/icon.png"),
		#		"config" = {
		#			"name" = "christmas_tree",
		#			"node" = preload("res://assets/nodes/buildings/christmas_tree/christmas_tree.tscn"),
		#			"shadow" = preload("res://assets/nodes/buildings/christmas_tree/christmas_tree_shadow.tscn"),
		#			"area" = Vector2i(1,1),
		#			"resources" = {
		#				
		#			}
		#		}
		#	},
	},
	
	"upgrades": {}
}
