extends Control

@onready var anim: AnimationPlayer = $Animation
@onready var close: Button = $Window/Close

@onready var container: GridContainer = $Window/HBoxContainer/InventoryContent/Panel/Margin/Scroll/Margin/GridContainer
@onready var icon: TextureRect = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/ItemIconContainer/Icon
@onready var title: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/HeaderContainer/Header
@onready var content: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/ContentContainer/Content
@onready var specifics: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/Specifications/Specifications
@onready var confirm: Button = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/ButtonContainer/Button
@onready var type: Label = $Window/HBoxContainer/ItemContent/ScrollContainer/VBox/Type/Type

const INVENTORY_SLOT_SIZE: Vector2i = Vector2i(64, 64)


func _ready() -> void:
	close.pressed.connect(_close)
	close.pressed.connect(UIManager.button_pressed)
	close.mouse_entered.connect(UIManager.button_hovered)
	close.mouse_exited.connect(UIManager.button_exited)
	anim.animation_finished.connect(
		func(anim_name: StringName) -> void:
			if anim_name != "show":
				UIManager.add_ui(UIManager.MENUS.HUD)
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
		confirm.visible = false
		return

	icon.texture = null
	title.text = tr("inventory.select_item.title")
	content.text = ""
	confirm.visible = false

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
			container.add_child(_slot_create(item, PlayerControl.inventory[item]["amount"]))


func _slot_create(item_id: int, item_value: int) -> Control:
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
	)

	button.pressed.connect(UIManager.button_pressed)
	button.mouse_entered.connect(UIManager.button_hovered)
	button.mouse_exited.connect(UIManager.button_exited)

	parent.add_child(button)
	parent.add_child(sprite)
	parent.add_child(value)

	return parent


func _close() -> void:
	UIManager.blur.blur(false)
	anim.play("hide")
