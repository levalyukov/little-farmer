extends Control

# ===================================================================
# (build_menu.gd)
# ===================================================================
# Управление UI-окном для работы с чертежами и постройками на ферме.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Создание возможность выбирать изученные чертежи игроком
# - Переход в режим стройки выбранного чертежа
#
# ЗАВИСИМОСТИ:
# - Utils - вспомогательные методы
# - UIManager - взаимодействие с пользовательским интерфейсом
# - AnimationPlayer - для плавного появления и скрытие интерфейса методом изменении модуляции
#
# ===================================================================

@onready var anim:AnimationPlayer = $Animation
@onready var navmenu:BoxContainer = $Main/ScrollContainer/NavMenu

@onready var node_icon:TextureRect = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/IconContainer/TextureRect
@onready var node_title:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/HeaderContainer/Header
@onready var node_description:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/DescriptionContainer/Description
@onready var node_resources:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ResourcesContainer/Resources
@onready var node_time:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/TimeContainer/Time
@onready var node_confirm:Button = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ButtonContainer/Button

@onready var container:GridContainer = $Main/MainContent/BlueprintsContent/ScrollContainer/GridContainer
@onready var confirm:Button = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ButtonContainer/Button
@onready var exit:Button = $Exit

enum Pages {ALL = -1, BUILDINGS, TERRAINS}
const ICON:CompressedTexture2D = preload("res://assets/resources/ui/interactive/construct/blueprint.png")

var page_index:Pages = Pages.ALL

var sections:Array[String] = [
	tr("build_menu.all_blueprints"),
	tr("build_menu.buildings"),
	tr("build_menu.terrains")
]


func _ready() -> void:
	_init_buttons()
	_update_page()
	_open()


func _update_page() -> void:
	if !container.get_children().is_empty():
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
	
	if PlayerControl.blueprints.has(page_index):
		if PlayerControl.blueprints[page_index].is_empty():
			_label_emtpy_create()
			return

		for i in PlayerControl.blueprints[page_index]:
			_button_blueprint_create(BlueprintsManager.blueprint_get(int(page_index), i))

	else:
		for id in PlayerControl.blueprints:
			if !PlayerControl.blueprints[id].is_empty():
				for j in PlayerControl.blueprints[id]:
					_button_blueprint_create(BlueprintsManager.blueprint_get(id, j))

func _button_blueprint_create(data:Dictionary) -> Control:
	if data.is_empty():
		return null

	var parent:Control = Control.new()
	var external_margin:MarginContainer = MarginContainer.new()
	var internal_margin:MarginContainer = MarginContainer.new()
	var button:Button = Button.new()
	var hcontainer:HBoxContainer = HBoxContainer.new()
	var icon:TextureRect = TextureRect.new()
	var label:Label = Label.new()

	parent.set_custom_minimum_size(Vector2i(0,64))
	parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL | Control.SIZE_FILL
	external_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	external_margin.set_anchors_preset(PRESET_TOP_WIDE)
	external_margin.add_theme_constant_override("margin_right",4)
	internal_margin.add_theme_constant_override("margin_right", 8)
	internal_margin.add_theme_constant_override("margin_left", 8)
	internal_margin.add_theme_constant_override("margin_top", 8)
	internal_margin.add_theme_constant_override("margin_bottom", 8)

	hcontainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	internal_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

	icon.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	icon.set_custom_minimum_size(Vector2i(48,48))

	button.pressed.connect(
		func() -> void:
			_info_set(data)
	)

	button.pressed.connect(UIManager.button_pressed)
	button.mouse_entered.connect(UIManager.button_hovered)
	button.mouse_exited.connect(UIManager.button_exited)

	icon.texture = data["icon"] if data.has("icon") && data["icon"] is CompressedTexture2D else ICON
	label.text = data["title"] if data.has("title") && data["title"] is String else "????????????????"

	container.add_child(parent)
	parent.add_child(external_margin)
	external_margin.add_child(button)
	external_margin.add_child(internal_margin)
	internal_margin.add_child(hcontainer)
	hcontainer.add_child(icon)
	hcontainer.add_child(label)

	return parent


func _info_set(data:Dictionary) -> void:
	if data.is_empty():
		return

	node_icon.texture 	= data["icon"] if data.has("icon") && data["icon"] is CompressedTexture2D else null
	node_title.text = data["title"] if data.has("title") && data["title"] is String else "??????"
	node_description.text = data["description"] if data.has("description") && data["description"] is String else ""
	# node_resources
	node_time.text = str(data["time"]) if data.has("time") && data["time"] is float else str(0.00)
	# node_confirm


func _label_emtpy_create() -> void:
	var label:Label = Label.new()

	label.text = "Пустота..."
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	container.add_child(label)


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

			button.pressed.connect(
				func() -> void: 
					match index:
						1: page_index = Pages.BUILDINGS
						2: page_index = Pages.TERRAINS
						_: page_index = Pages.ALL
					_update_page()
			)

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
