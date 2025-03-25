extends Node

class_name BlueprintManager
@onready var main = str(get_tree().root.get_child(2).name)
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
var content:Dictionary = {
	"terrains": {
		1: {
			"caption" = tr("Тропинки"),
			"description" = tr('Позволяет создавать тропы и вспахиваемую землю.\n\n-- Пошаговое объяснение --\n\n1. Расчистите место: Выберите пустой участок размером 3x3 клеток\n\n2. Создайте тропы: Превратите все клетки вокруг центральной в тропы\n\n3. Получите грядку: В центре образуется готовая к вспашке земля.'),
			"icon" = load("res://assets/resources/ui/interactive/construct/roads.png"),
			"config" = {
				"terrain" = [0],
				"required_layer" = [1],
				"blocking_layer" = [1,2,3,5],
			},

			"trade_info" = {
				"caption" = tr("Чертеж тропинок"),
				"description" = tr('Позволяет создавать тропы и вспахиваемую землю.'),
				"price" = 100
			}
		},
		2: {
			"caption" = tr("Водоём"),
			"description" = tr('Создавайте водоёмы на своей ферме.'),
			"icon" = load("res://assets/resources/ui/interactive/construct/water.png"),
			"config" = {
				"terrain" = [3,4],
				"required_layer" = [3,5],
				"blocking_layer" = [1,2,3,9],
			},

			"trade_info" = {
				"caption" = tr("Чертеж водоёма"),
				"description" = tr("С помощью этого чертежа можно создавать водоёмы на своей ферме."),
				"price" = 500
			}
		},
	},
	
	"nodes": {
		1: {
			"caption" = tr("Деревянный знак"),
			"description" = tr("Позволяет разместить изображение любого предмета."),
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
				"caption" = tr("Чертеж деревянного знака"),
				"description" = tr("Позволяет разместить изображение любого предмета. К примеру, помогает пометить какая культура растет на грядках."),
				"price" = 250
			}
		},
		2: {
			"caption" = tr("Компостер"),
			"description" = tr("Ящик для приготовления удобрения."),
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
				"caption" = tr("Чертеж компостера"),
				"description" = tr("Компостер — полезный инструмент для каждого фермера. Позволяет переработать отходы в удобрение для вашего растения."),
				"price" = 750
			}
		},
		3: {
			"caption" = tr("Колодец"),
			"description" = tr("Позволяет пополять лейку."),
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
				"caption" = tr("Чертеж колодца"),
				"description" = tr("Одна из полезных построек на вашей ферме — позволяет быстро наполнить лейку водой."),
				"price" = 1000
			}
		},
		4: {
			"caption" = tr("Хлев"),
			"description" = tr("Место для содержания скота."),
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
				"caption" = tr("Чертеж хлева"),
				"description" = tr("Данная постройка позволяет завести скот*.\n\n* - скот будет добавлен в будущих обновлениях."),
				"price" = 5000
			}
		},
		5: {
			"caption" = tr("Силосная башня"),
			"description" = tr("Высокое и вместительное хранилище для кормов."),
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
				"caption" = tr("Чертеж силосной башни"),
				"description" = tr("Позволяет хранить корм для скота."),
				"price" = 2500
			}
		},
		6: {
			"caption" = tr("Теплица"),
			"description" = tr("Тёплое помещение для разведения и выращивания растений."),
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
				"caption" = tr("Чертеж теплицы"),
				"description" = tr("Позволяет выращивать культуры вне зависимости от времени года. Имеет площадь 8х8 клеток."),
				"price" = 20000
			}
		},
		7: {
			"caption" = tr("Фонарный столб"),
			"description" = tr("Источник света для вашей фермы."),
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
				"caption" = tr("Чертеж фонарного столба"),
				"description" = tr("Источник света для вашей фермы."),
				"price" = 1000
			}
		},
		8: {
			"caption" = tr("Дорожка из больших камней"),
			"description" = tr("Небольшая декоративная дорожка из камней."),
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
				"caption" = tr("Чертеж дорожки из больших камней"),
				"description" = tr("Небольшая декоративная дорожка из камней."),
				"price" = 500
			}
		},
		9: {
			"caption" = tr("Каменная плавильная печь"),
			"description" = tr("Простая каменная плавильня для обработки ресурсов. Недорогая в создании, работает медленно и требует времени для плавки."),
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
				"caption" = tr("Чертеж каменной плавильной печи"),
				"description" = tr("Простая каменная плавильня для обработки ресурсов."),
				"price" = 2000
			}
		},
		10: {
			"caption" = tr("Радио"),
			"description" = tr("Позволяет воспроизводить радиостанции и пользовательские треки.\n\nМожет быть только в единном экземпляре."),
			"icon" = load("res://assets/resources/buildings/radio/obj_0.png"),
			"config" = {
				"name" = "radio",
				"node" = load("res://assets/nodes/buildings/radio.tscn"),
				"shadow" = load("res://assets/nodes/buildings/radio_shadow.tscn"),
				"area" = Vector2i(1,1),
				"onlyInstance" = true,
			},

			"trade_info" = {
				"caption" = tr("Радио"),
				"description" = tr("Позволяет воспроизводить радиостанции, слушать новости и включать пользовательские песни."),
				"price" = 7500
			}
		},
		11: {
			"caption" = tr("Пилостол"),
			"description" = tr("Позволяет распилить бревна на доски."),
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
				"caption" = tr("Чертеж пилостола"),
				"description" = tr("При помощи пилостола можно быстро распилить бревна на доски."),
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
		#			"resources" = {
		#				
		#			}
		#		}
		#	},
	},
	
	"upgrades": {}
}
