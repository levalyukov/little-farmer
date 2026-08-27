extends Node2D

@onready var cycle = get_tree().current_scene.cycle
@onready var collision: Area2D = $Collision
@onready var sprite: Sprite2D = $Sprite2D

const TEXTURES: Dictionary = {
	0: preload("res://assets/resources/buildings/storage/spring/sprite.png"),
	1: preload("res://assets/resources/buildings/storage/summer/sprite.png"),
	2: preload("res://assets/resources/buildings/storage/autumn/sprite.png"),
	3: preload("res://assets/resources/buildings/storage/winter/sprite.png")
}

const HOVERED: Dictionary = {
	0: preload("res://assets/resources/buildings/storage/spring/hover.png"),
	1: preload("res://assets/resources/buildings/storage/summer/hover.png"),
	2: preload("res://assets/resources/buildings/storage/autumn/hover.png"),
	3: preload("res://assets/resources/buildings/storage/winter/hover.png")
}

var mouse_entered: bool = false


func _ready() -> void:
	if !is_instance_valid(cycle):
		printerr("WorldCycle node is NULL.")
		return

	if !TEXTURES.is_empty() && sprite:
		sprite.texture = TEXTURES[cycle.season_id]

	if collision:
		collision.mouse_entered.connect(_collision_mouse_entered)
		collision.mouse_exited.connect(_collision_mouse_exited)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		&& mouse_entered
		&& event.pressed
		&& !UIManager.blur.state
		&& event.button_index == MOUSE_BUTTON_LEFT
	):
		UIManager.ui_remove(UIManager.ui_get(UIManager.MENUS.HUD.get_state().get_node_name(0)))
		UIManager.ui_add(UIManager.MENUS.INVENTORY)

		if TEXTURES.has(cycle.season_id) && TEXTURES[cycle.season_id] is CompressedTexture2D:
			sprite.texture = TEXTURES[cycle.season_id]

		if UIManager.cursor:
			UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)


func _collision_mouse_entered() -> void:
	if !UIManager.ui_get("HUD"):
		return

	self.mouse_entered = true

	if HOVERED.has(cycle.season_id) && HOVERED[cycle.season_id] is CompressedTexture2D:
		sprite.texture = HOVERED[cycle.season_id]

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _collision_mouse_exited() -> void:
	self.mouse_entered = false

	if !UIManager.ui_get("HUD"):
		return

	if TEXTURES.has(cycle.season_id) && TEXTURES[cycle.season_id] is CompressedTexture2D:
		sprite.texture = TEXTURES[cycle.season_id]

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
