class_name Cursor extends Node2D

enum States { DEFAULT, ACTIVE }
const CURSOR: Dictionary = {
	States.DEFAULT:
	{
		"static": preload("res://assets/resources/ui/interactive/hud/cursor/static.png"),
		"active": preload("res://assets/resources/ui/interactive/hud/cursor/active.png"),
	},
	States.ACTIVE:
	{
		"static": preload("res://assets/resources/ui/interactive/hud/cursor/clicked_default.png"),
		"active": preload("res://assets/resources/ui/interactive/hud/cursor/clicked_active.png"),
	}
}

var state: States = States.DEFAULT


func _ready() -> void:
	set_cursor(States.DEFAULT)


func set_cursor(new_state: States) -> void:
	state = new_state
	if CURSOR.has(state) && CURSOR[state].has("static"):
		Input.set_custom_mouse_cursor(CURSOR[state]["static"], Input.CURSOR_ARROW, Vector2(0, 0))


func _input(event: InputEvent) -> void:
	if !CURSOR.has(state):
		return

	match state:
		States.DEFAULT:
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

		States.ACTIVE:
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
