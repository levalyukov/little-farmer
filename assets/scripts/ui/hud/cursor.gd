class_name Cursor extends Node2D

const STATIC: CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/cursor/static.png")
const ACTIVE: CompressedTexture2D = preload("res://assets/resources/ui/interactive/hud/cursor/active.png")


func _ready() -> void:
	Input.set_custom_mouse_cursor(STATIC, Input.CURSOR_ARROW, Vector2(0, 0))


func _input(event: InputEvent) -> void:
	if STATIC && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_released():
		Input.set_custom_mouse_cursor(STATIC, Input.CURSOR_ARROW, Vector2(0, 0))

	if ACTIVE && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
		Input.set_custom_mouse_cursor(ACTIVE, Input.CURSOR_ARROW, Vector2(0, 0))
