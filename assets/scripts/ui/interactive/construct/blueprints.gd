extends Node

class_name Blueprints
var content: Dictionary = {
	1: {
		"caption" = "Тропинка",
		"description" = "",
		"time" = 1,
		"icon" = load("res://assets/resources/ui/interactive/hud/grid/default.png"),
		"type" = {
			"terrain" = {
				"terrain_set" = 2,
			},
		},
	},
	2: {
		"caption" = "Деревянный знак",	# Деревянный знак Позволяет разместить изображение любого предмета
		"description" = "Позволяет разместить изображение любого предмета.", #	Деревянные дорожки для сада добавляют уют и красоту вашему пространству
		"resource" = {
			"plank" = 5,
			"stone" = 5,
			"log" = 5,
			},
		"time" = 5,
		"icon" = load("res://assets/resources/buildings/sign/sign_0.png"),
		"type" = {
			"node" = {
				"source" = load("res://assets/nodes/buildings/sign.tscn"),
				"shadow" = load("res://assets/resources/buildings/sign/shadow.png"),
				"name" = "sign",
			},
		},
	},
	3: {
		"caption" = "Деревянный дом",
		"description" = "Улучшение для дома.",
		"time" = 1,
		"icon" = load("res://assets/resources/buildings/house/level_2/object_0.png"),
		"resource" = {
			"plank" = 75,
			},
		"type" = {
			"upgrade" = {
				"level.up" = 2,
			},
		},
	},
	#4: {
	#	"caption" = "Компостер",
	#	"description" = "Простой и недорогой компостер для разложения органического материала.",
	#	"resource" = {
	#		"plank" = 25,
	#		},
	#	"time" = 15,
	#	"icon" = null,#load("res://assets/resources/UI/building menu/sprite_0.png"),
	#	"content" = {
	#		"object.name" = "",
	#		"node" = load(""),
	#	},
	#},
	#5: {
	#	"caption" = "Бочка",
	#	"description" = "Ёмкость для сбора и хранения дождевой воды для полива растений, мытья автомобилей или других задач.",
	#	"resource" = {
	#		"plank" = 75,
	#		},
	#	"time" = 60,
	#	"icon" = null,#load("res://assets/resources/UI/building menu/sprite_0.png"),
	#	"content" = null,#load(""),
	#},
	#6: {
	#	"caption" = "Колодец",
	#	"description" = "Глубокая яма с каменной обшивкой, используемая для доступа к подземным источникам воды.",
	#	"resource" = {
	#		"plank" = 100,
	#		"stone" = 250,
	#		},
	#	"time" = 12,
	#	"icon" = null,#load("res://assets/resources/UI/building menu/sprite_0.png"),
	#	"content" = null,#load(""),
	#},
}
