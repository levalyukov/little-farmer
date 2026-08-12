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
	_info_clear()
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

		for id in PlayerControl.blueprints[page_index]:
			_button_blueprint_create(page_index, id)

	else:
		for type in PlayerControl.blueprints:
			if !PlayerControl.blueprints[type].is_empty():
				for id in PlayerControl.blueprints[type]:
					_button_blueprint_create(type, id)


func _button_blueprint_create(blueprint_type:int, blueprint_id:int) -> Control:
	var data:Dictionary = BlueprintsManager.blueprint_get(blueprint_type, blueprint_id);

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
			_info_set(data, blueprint_type, blueprint_id)
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


func _info_set(data:Dictionary, blueprint_type:int, blueprint_id:int = 0) -> void:
	if data.is_empty():
		return

	var total_time:float = data["time"]/60.0 if data.has("time") && data["time"] is float else 0.00

	node_icon.texture 	= data["icon"] if data.has("icon") && data["icon"] is CompressedTexture2D else null
	node_title.text = data["title"] if data.has("title") && data["title"] is String else "??????"
	node_description.text = data["description"] if data.has("description") && data["description"] is String else ""

	if data.has("resources") \
	&& !data["resources"].is_empty()\
	&& data["resources"] is Dictionary:
		node_resources.text = ""
		if !node_resources.visible:
			node_resources.visible = true

		for type in data["resources"]:
			for id in data["resources"][type]:
				var item:Dictionary = Items.items_get(type, id)
				var amount:int = data["resources"][type][id]["amount"]\
				if (data["resources"][type][id].has("amount") \
				&& data["resources"][type][id]["amount"] is int) else 0
				if !item.is_empty() && amount > 0:
					node_resources.text += "• " + item["title"] + " (" + ("0" + "/" + str(amount)) + ")\n"

	else:
		node_resources.text = ""
		node_resources.visible = false

	node_time.text = tr("build_menu.build_total_time")+": "+str(total_time)

	if !node_confirm.visible:
		node_confirm.text = "build_menu.button.apply"
		node_confirm.visible = true
		node_confirm.disabled = false

		if node_confirm.pressed.is_connected(_button_build):
			node_confirm.pressed.disconnect(_button_build)
		
		node_confirm.pressed.connect(_button_build.bind(blueprint_type, blueprint_id))


func _button_build(blueprint_type:int, blueprint_id:int) -> void:
	var scene:Node = get_tree().current_scene
	if is_instance_valid(scene.build):
		scene.build.grid_add(scene.build.GridModes.BUILD)

	_close()


func _info_clear() -> void:
	node_icon.texture = null
	node_title.text = ""
	node_description.text = ""
	node_resources.text = ""
	node_time.text = ""

	if node_confirm.visible:
		node_confirm.text = ""
		node_confirm.visible = false


func _label_emtpy_create() -> void:
	var label:Label = Label.new()
	label.text = tr("build_menu.empty")
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
