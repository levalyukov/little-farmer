extends Control

# =============================================================================================
# (hud.gd)
# =============================================================================================
# Скрипт поведения HUD.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Инициализация кнопок 
# - Взаимодействия с менеджерами сцены
#
# ЗАВИСИМОСТИ:
# - UIManager - взаимодействие с пользовательским интерфейсом
# - AnimationPlayer - для плавного появления и скрытие интерфейса методом изменении модуляции
#
# =============================================================================================

@onready var anim:AnimationPlayer         		= $Animation

@onready var destroy:Button               		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Destroy/Main/Button
@onready var farming:Button               		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Farming/Main/Button
@onready var watering:Button              		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Watering/Main/Button
@onready var harvest:Button               		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Harvest/Main/Button
@onready var build:Button                 		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Build/Main/Button
@onready var destroy_icon:TextureRect     		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Destroy/Main/Margin/Icon
@onready var farming_icon:TextureRect     		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Farming/Main/Margin/Icon
@onready var watering_icon:TextureRect    		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Watering/Main/Margin/Icon
@onready var harvest_texture:TextureRect  		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Harvest/Main/Margin/Icon
@onready var build_icon:TextureRect       		= $Main/Tools/Control/MarginContainer/MarginContainer/HBoxContainer/Build/Main/Margin/Icon

@onready var destroy_anim:AnimationPlayer 		= $Main/DestroyMenuMargin/Control/Animation
@onready var destroy_menu:Control         		= $Main/DestroyMenuMargin
@onready var destroy_terrains:Button			= $Main/DestroyMenuMargin/Control/MarginContainer/HBoxContainer/Terrains/Main/Button
@onready var destroy_nature:Button				= $Main/DestroyMenuMargin/Control/MarginContainer/HBoxContainer/Nature/Main/Button
@onready var destroy_buildings:Button			= $Main/DestroyMenuMargin/Control/MarginContainer/HBoxContainer/Buildings/Main/Button
@onready var destroy_terrains_icon:TextureRect 	= $Main/DestroyMenuMargin/Control/MarginContainer/HBoxContainer/Terrains/Main/Margin/Icon
@onready var destroy_nature_icon:TextureRect 	= $Main/DestroyMenuMargin/Control/MarginContainer/HBoxContainer/Nature/Main/Margin/Icon
@onready var destroy_buildings_icon:TextureRect = $Main/DestroyMenuMargin/Control/MarginContainer/HBoxContainer/Buildings/Main/Margin/Icon

const ICONS:Dictionary =\
{
	0: preload("res://assets/resources/ui/interactive/hud/tools/trash.png"),
	1: preload("res://assets/resources/ui/interactive/hud/tools/hoe.png"),
	2: preload("res://assets/resources/ui/interactive/hud/tools/sickle.png"),
	3: preload("res://assets/resources/ui/interactive/hud/tools/watering_can.png"),
	4: preload("res://assets/resources/ui/interactive/hud/tools/hammer.png"),
	5: preload("res://assets/resources/ui/interactive/hud/tools/destroy_terrains.png"),
	6: preload("res://assets/resources/ui/interactive/hud/tools/destroy_plant.png"),
	7: preload("res://assets/resources/ui/interactive/hud/tools/destroy_buildings.png")
} 

func _ready() -> void:
	self.visible = true
	destroy_menu.visible = false

	anim.animation_finished.connect(
		func(animation_name:String) -> void:
			if animation_name != "show":
				UIManager.ui_remove(self)
	)

	destroy_anim.animation_finished.connect(
		func(animation_name:String) -> void:
			if animation_name != "show":
				destroy_menu.visible = false
	)

	anim.play("show")
	destroy_anim.play("hide")
	_button_init()

func _button_init() -> void:
	destroy_icon.texture    		= ICONS[0] if ICONS[0] is CompressedTexture2D else null
	farming_icon.texture    		= ICONS[1] if ICONS[1] is CompressedTexture2D else null
	watering_icon.texture   		= ICONS[2] if ICONS[2] is CompressedTexture2D else null
	harvest_texture.texture 		= ICONS[3] if ICONS[3] is CompressedTexture2D else null
	build_icon.texture      		= ICONS[4] if ICONS[4] is CompressedTexture2D else null
	destroy_terrains_icon.texture 	= ICONS[5] if ICONS[5] is CompressedTexture2D else null
	destroy_nature_icon.texture 	= ICONS[6] if ICONS[6] is CompressedTexture2D else null
	destroy_buildings_icon.texture 	= ICONS[7] if ICONS[7] is CompressedTexture2D else null

	destroy.pressed.connect(
		func() -> void:
			if !destroy_menu.visible:
				destroy_menu.visible = true
				destroy_anim.play("show")
			else:
				destroy_anim.play("hide")
	)
	farming.pressed.connect(
		func() -> void:
			_close()
	)
	watering.pressed.connect(
		func() -> void:
			_close()
	)
	harvest.pressed.connect(
		func() -> void:
			_close()
	)
	build.pressed.connect(
		func() -> void:
			_close()
	)

	destroy.pressed.connect(UIManager._button_pressed)
	farming.pressed.connect(UIManager._button_pressed)
	watering.pressed.connect(UIManager._button_pressed)
	harvest.pressed.connect(UIManager._button_pressed)
	build.pressed.connect(UIManager._button_pressed)

	destroy.mouse_entered.connect(UIManager._button_hovered)
	farming.mouse_entered.connect(UIManager._button_hovered)
	watering.mouse_entered.connect(UIManager._button_hovered)
	harvest.mouse_entered.connect(UIManager._button_hovered)
	build.mouse_entered.connect(UIManager._button_hovered)

	destroy.mouse_exited.connect(UIManager._button_exited)
	farming.mouse_exited.connect(UIManager._button_exited)
	watering.mouse_exited.connect(UIManager._button_exited)
	harvest.mouse_exited.connect(UIManager._button_exited)
	build.mouse_exited.connect(UIManager._button_exited)

	destroy_terrains.pressed.connect(UIManager._button_pressed)
	destroy_nature.pressed.connect(UIManager._button_pressed)
	destroy_buildings.pressed.connect(UIManager._button_pressed)

	destroy_terrains.pressed.connect(
		func() -> void:
			_close()
	)
	destroy_nature.pressed.connect(
		func() -> void:
			_close()
	)
	destroy_buildings.pressed.connect(
		func() -> void:
			_close()
	)

	destroy_terrains.mouse_entered.connect(UIManager._button_hovered)
	destroy_nature.mouse_entered.connect(UIManager._button_hovered)
	destroy_buildings.mouse_entered.connect(UIManager._button_hovered)

	destroy_terrains.mouse_exited.connect(UIManager._button_exited)
	destroy_nature.mouse_exited.connect(UIManager._button_exited)
	destroy_buildings.mouse_exited.connect(UIManager._button_exited)

func _close() -> void:
	anim.play("hide")
