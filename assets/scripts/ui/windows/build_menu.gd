extends Control

# ===================================================================
# (build_menu.gd)
# ===================================================================
# Управление UI-окном для работы с чертежами и постройками на ферме.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - 
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# -
#
# ЗАВИСИМОСТИ:
# - Utils - вспомогательные методы
# - UIManager - взаимодействие с пользовательским интерфейсом
# - AnimationPlayer - для плавного появления и скрытие интерфейса методом изменении модуляции
#
# ===================================================================

@onready var anim:AnimationPlayer = $Animation

@onready var navmenu:BoxContainer = $Main/ScrollContainer/NavMenu
@onready var container:GridContainer = $Main/MainContent/BlueprintsContent/ScrollContainer/GridContainer
@onready var confirm:Button = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ButtonContainer/Button
@onready var exit:Button = $Exit

const BLUEPRINT_ICON:CompressedTexture2D = preload("res://assets/resources/ui/interactive/construct/blueprint.png")
var page_index:int = 0
var sections:Array[String] = [
	tr("build_menu.all_blueprints"),
	tr("build_menu.buildings"),
	tr("build_menu.terrains")
]

func _ready() -> void:
	_init_buttons()
	_init_blueprints()
	_open()


func _init_blueprints() -> void:
	var blueprints:Dictionary = PlayerControl.player_get()

	if !blueprints.is_empty() && !blueprints["blueprints"].is_empty():
		for index in blueprints["blueprints"]:
			var parent:Control = Control.new()
			var external_margin:MarginContainer = MarginContainer.new()
			var internal_margin:MarginContainer = MarginContainer.new()
			var button:Button = Button.new()
			var hcontainer:HBoxContainer = HBoxContainer.new()
			var icon:TextureRect = TextureRect.new()
			var label:Label = Label.new()

			parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL | Control.SIZE_FILL

			external_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
			internal_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hcontainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			external_margin.set_anchors_preset(PRESET_TOP_WIDE)
			external_margin.add_theme_constant_override("margin_right",4)
			internal_margin.add_theme_constant_override("margin_right", 8)
			internal_margin.add_theme_constant_override("margin_left", 8)
			internal_margin.add_theme_constant_override("margin_top", 8)
			internal_margin.add_theme_constant_override("margin_bottom", 8)
			icon.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
			icon.set_custom_minimum_size(Vector2i(48,48))
			icon.texture = BLUEPRINT_ICON
			label.text = "????????????????"
			button.pressed.connect(UIManager.button_pressed)
			button.mouse_entered.connect(UIManager.button_hovered)
			button.mouse_exited.connect(UIManager.button_exited)

			container.add_child(parent)
			parent.add_child(external_margin)
			external_margin.add_child(button)
			external_margin.add_child(internal_margin)
			internal_margin.add_child(hcontainer)
			hcontainer.add_child(icon)
			hcontainer.add_child(label)

			parent.set_custom_minimum_size(Vector2i(0,64))


func _init_buttons() -> void:
	confirm.pressed.connect(
		func() -> void:
			if confirm.visible && !confirm.disabled:
				UIManager.button_pressed()
	)

	confirm.mouse_entered.connect(
		func() -> void:
			if confirm.visible && !confirm.disabled:
				UIManager.button_hovered()
	)

	confirm.mouse_exited.connect(
		func() -> void:
			if confirm.visible && !confirm.disabled:
				UIManager.button_exited()
	)

	exit.pressed.connect(func() -> void: _close())
	exit.pressed.connect(UIManager.button_pressed)
	exit.mouse_entered.connect(UIManager.button_hovered)
	exit.mouse_exited.connect(UIManager.button_exited)

	if navmenu && navmenu.get_children().is_empty() && !sections.is_empty():
		for index in sections.size():
			var button:Button = Button.new()
			button.text = sections[index]
			button.pressed.connect(func() -> void: page_index = index)
			button.pressed.connect(UIManager.button_pressed)
			button.mouse_entered.connect(UIManager.button_hovered)
			button.mouse_exited.connect(UIManager.button_exited)
			navmenu.add_child(button)

func _open() -> void: 
	self.visible = true
	anim.animation_finished.connect(_anim_is_finished)
	UIManager.blur.blur(true)
	anim.play("show")

func _close() -> void:
	if navmenu && !navmenu.get_children().is_empty():
		for button in navmenu.get_children():
			var ptr:Button = button
			navmenu.remove_child(ptr)
			ptr.queue_free()

	UIManager.ui_add(UIManager.MENUS.HUD)
	UIManager.blur.blur(false)
	anim.play("hide")

func _anim_is_finished(anim_name: String) -> void:
	if anim_name != "show":
		UIManager.ui_remove(self)
