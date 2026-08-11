class_name Cursor extends Node2D

# =============================================================================================
#  (cursor.gd)
# =============================================================================================
# Меняет системную мышь на игровую текстуру
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Смена состояния игрового курсора
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - set_cursor(new_state:STATES) - смена состояния курсора
#
# =============================================================================================

enum STATES { DEFAULT, ACTIVE }
const CURSOR: Dictionary = {
	STATES.DEFAULT:
	{
		"static": preload("res://assets/resources/ui/interactive/hud/cursor/cursor_static.png"),
		"active": preload("res://assets/resources/ui/interactive/hud/cursor/cursor_active.png"),
	},
	
	STATES.ACTIVE:
	{
		"static": preload("res://assets/resources/ui/interactive/hud/cursor/clicked_default.png"),
		"active": preload("res://assets/resources/ui/interactive/hud/cursor/clicked_active.png"),
	}
}

var state: STATES = STATES.DEFAULT


func _ready() -> void:
	set_cursor(STATES.DEFAULT)


func set_cursor(new_state: STATES) -> void:
	state = new_state
	if CURSOR.has(state) && CURSOR[state].has("static"):
		Input.set_custom_mouse_cursor(CURSOR[state]["static"], Input.CURSOR_ARROW, Vector2(0, 0))


func _input(event: InputEvent) -> void:
	if !CURSOR.has(state):
		return

	match state:
		STATES.DEFAULT:
			if (
				CURSOR[state].has("static")
				&& event is InputEventMouseButton
				&& event.button_index == MOUSE_BUTTON_LEFT
				&& event.is_released()
			):
				Input.set_custom_mouse_cursor(CURSOR[state]["static"], Input.CURSOR_ARROW, Vector2(0, 0))

			if (
				CURSOR[state].has("active")
				&& event is InputEventMouseButton
				&& event.button_index == MOUSE_BUTTON_LEFT
				&& event.is_pressed()
			):
				Input.set_custom_mouse_cursor(CURSOR[state]["active"], Input.CURSOR_ARROW, Vector2(0, 0))

		STATES.ACTIVE:
			if (
				CURSOR[state].has("active")
				&& event is InputEventMouseButton
				&& event.button_index == MOUSE_BUTTON_LEFT
				&& event.is_pressed()
			):
				Input.set_custom_mouse_cursor(CURSOR[state]["active"], Input.CURSOR_ARROW, Vector2(0, 0))

			if (
				CURSOR[state].has("static")
				&& event is InputEventMouseButton
				&& event.button_index == MOUSE_BUTTON_LEFT
				&& event.is_released()
			):
				Input.set_custom_mouse_cursor(CURSOR[state]["static"], Input.CURSOR_ARROW, Vector2(0, 0))

		_:
			pass
