extends Control

@onready var build: BuildManager = get_tree().current_scene.build

@onready var anim: AnimationPlayer = $Animation
@onready var close: Button = $Window/Close

@onready var container: GridContainer = $Window/HBoxContainer/InventoryContent/Panel/Margin/Scroll/Margin/GridContainer
@onready var icon: TextureRect = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/ItemIconContainer/Icon
@onready var title: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/HeaderContainer/Header
@onready var content: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/ContentContainer/Content
@onready var specifics: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/Specifications/Specifications
@onready var apply: Button = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/ButtonContainer/Apply
@onready var type: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/Type/Type

const INVENTORY_SLOT_SIZE: Vector2i = Vector2i(64, 64)

var selected_item_id: int = 0
var selected_item_type: Items.ItemsType = Items.ItemsType.NONE


func _ready() -> void:
	close.pressed.connect(_close)
	close.pressed.connect(UIManager.button_pressed)
	close.mouse_entered.connect(UIManager.button_hovered)

	apply.pressed.connect(UIManager.button_pressed)
	apply.mouse_entered.connect(UIManager.button_hovered)

	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				UIManager.remove_ui(self)
	)

	UIManager.blur.blur(true)
	SoundManager.play_sound("ui/inventory")
	anim.play("show")
	update()


func update() -> void:
	if PlayerControl.inventory.is_empty():
		icon.texture = null
		title.text = tr("inventory.empty.title")
		content.text = ""
		apply.visible = false
		return

	icon.texture = null
	title.text = tr("inventory.select_item.title")
	content.text = ""
	apply.visible = false

	if !container.get_children().is_empty():
		for items in get_children():
			container.remove_child(items)
			items.queue_free()

	for item in PlayerControl.inventory.keys():
		if (
			PlayerControl.inventory.has(item)
			&& PlayerControl.inventory[item] is Dictionary
			&& PlayerControl.inventory[item].has("amount")
		):
			container.add_child(_item_slot_create(item, PlayerControl.inventory[item]["amount"]))


func _item_slot_create(item_id: int, item_value: int) -> Control:
	var parent: Control = Control.new()
	var button: Button = Button.new()
	var sprite: TextureRect = TextureRect.new()
	var value: Label = Label.new()
	var data: Dictionary = Items.get_item(item_id)

	parent.set_custom_minimum_size(INVENTORY_SLOT_SIZE)
	button.set_custom_minimum_size(INVENTORY_SLOT_SIZE)
	sprite.set_custom_minimum_size(INVENTORY_SLOT_SIZE)
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.texture = data["icon"] if data.has("icon") && data["icon"] is CompressedTexture2D else null
	value.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	value.text = str(item_value) + "x" if item_value > 0 else ""

	button.pressed.connect(
		func() -> void:
			icon.texture = data["icon"]
			title.text = data["title"]
			content.text = data["description"]
			type.text = Items.get_item_type(data["type"])

			self.selected_item_id = item_id
			self.selected_item_type = data["type"]
			_refresh_action_button(data)
	)

	button.pressed.connect(UIManager.button_pressed)
	button.mouse_entered.connect(UIManager.button_hovered)

	parent.add_child(button)
	parent.add_child(sprite)
	parent.add_child(value)

	return parent


func _refresh_action_button(data: Dictionary) -> void:
	#* --------------------------------------- *#
	# * Наверняка я дичь редкостную делаю,	  * #
	# * ибо мне не нравится такая реализация. * #
	# * 									  * #
	# * Позже надо покуметь, ибо такая		  * #
	# * манипуляция с лямбдами наверняка не	  * #
	# * лучший способ динамически работать	  * #
	# * с предметами, которые могут иметь	  * #
	# * разные данные и способы работы...	  * #
	#* --------------------------------------- *#

	if self.selected_item_id == 0 || self.selected_item_type == Items.ItemsType.NONE:
		return

	apply.visible = true
	if apply.pressed.is_connected(_action_button):
		apply.pressed.disconnect(_action_button)

	match self.selected_item_type:
		Items.ItemsType.SEEDS:
			apply.text = tr("inventory.seeds.apply")
			apply.pressed.connect(_action_button.bind(data))

		_:
			apply.visible = false


func _action_button(data: Dictionary) -> void:
	if !data.has("type"):
		return

	match data["type"]:
		Items.ItemsType.SEEDS:
			if is_instance_valid(build):
				var grid: Node2D = build.grid_add(BuildManager.GridModes.PLANT)
				if grid != null:
					grid.plant = Crops.get_crop(data["data"]["plant_id"])

				self._close(true)


func _close(without_hud: bool = false) -> void:
	if !without_hud:
		UIManager.add_ui(UIManager.MENUS.HUD)

	UIManager.blur.blur(false)
	anim.play("hide")
