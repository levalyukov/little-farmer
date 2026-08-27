extends Node2D

@onready var cycle = get_tree().current_scene.cycle
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: Area2D = $Collision

const HOVERED: Dictionary = {
	0: preload("res://assets/resources/buildings/well/spring/hover.png"),
	1: preload("res://assets/resources/buildings/well/summer/hover.png"),
	2: preload("res://assets/resources/buildings/well/autumn/hover.png"),
	3: preload("res://assets/resources/buildings/well/winter/hover.png")
}

const TEXTURES: Dictionary = {
	0: preload("res://assets/resources/buildings/well/spring/sprite.png"),
	1: preload("res://assets/resources/buildings/well/summer/sprite.png"),
	2: preload("res://assets/resources/buildings/well/autumn/sprite.png"),
	3: preload("res://assets/resources/buildings/well/winter/sprite.png")
}

const DESTROY: Dictionary = {
	0: preload("res://assets/resources/buildings/well/spring/destroy.png"),
	1: preload("res://assets/resources/buildings/well/summer/destroy.png"),
	2: preload("res://assets/resources/buildings/well/autumn/destroy.png"),
	3: preload("res://assets/resources/buildings/well/winter/destroy.png")
}


func _ready() -> void:
	if !is_instance_valid(cycle):
		printerr("WorldCycle node is NULL.")
		return

	if !TEXTURES.is_empty() && sprite:
		sprite.texture = TEXTURES[cycle.season_id]

	if collision:
		collision.mouse_entered.connect(_collision_mouse_entered)
		collision.mouse_exited.connect(_collision_mouse_exited)


func _collision_mouse_entered() -> void:
	if !UIManager.ui_get("HUD"):
		return

	if HOVERED.has(cycle.season_id) && HOVERED[cycle.season_id] is CompressedTexture2D:
		sprite.texture = HOVERED[cycle.season_id]

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _collision_mouse_exited() -> void:
	if !UIManager.ui_get("HUD"):
		return

	if TEXTURES.has(cycle.season_id) && TEXTURES[cycle.season_id] is CompressedTexture2D:
		sprite.texture = TEXTURES[cycle.season_id]

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
