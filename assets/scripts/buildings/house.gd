extends Node2D

@onready var cycle = get_tree().current_scene.cycle
@onready var collision: Area2D = $Collision
@onready var sprite: Sprite2D = $Sprite2D

const TEXTURES: Dictionary = {
	0: preload("res://assets/resources/buildings/house/spring/sprite.png"),
	1: preload("res://assets/resources/buildings/house/summer/sprite.png"),
	2: preload("res://assets/resources/buildings/house/autumn/sprite.png"),
	3: preload("res://assets/resources/buildings/house/winter/sprite.png")
}

const HOVERED: Dictionary = {
	0: preload("res://assets/resources/buildings/house/spring/hover.png"),
	1: preload("res://assets/resources/buildings/house/summer/hover.png"),
	2: preload("res://assets/resources/buildings/house/autumn/hover.png"),
	3: preload("res://assets/resources/buildings/house/winter/hover.png")
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
	if !UIManager.get_ui("HUD"):
		return

	if HOVERED.has(cycle.season_id) && HOVERED[cycle.season_id] is CompressedTexture2D:
		sprite.texture = HOVERED[cycle.season_id]

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func _collision_mouse_exited() -> void:
	if !UIManager.get_ui("HUD"):
		return

	if TEXTURES.has(cycle.season_id) && TEXTURES[cycle.season_id] is CompressedTexture2D:
		sprite.texture = TEXTURES[cycle.season_id]

	if UIManager.cursor:
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
