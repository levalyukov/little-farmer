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

var cursor_state:States = States.DEFAULT
var current_cursor_node:Node = null

func _ready() -> void:
	Input.set_custom_mouse_cursor(
		CURSOR[cursor_state]["static"], 
		Input.CURSOR_ARROW, Vector2(0, 0)
	)

func change_cursor(node:Node, state:States) -> void:
	cursor_state = state
	current_cursor_node = node
	Input.set_custom_mouse_cursor(
		CURSOR[cursor_state]["static"], 
		Input.CURSOR_ARROW, Vector2(0, 0)
	)

func reset_cursor(node:Node) -> void:
	if current_cursor_node == node:
		cursor_state = States.DEFAULT
		current_cursor_node = node
		Input.set_custom_mouse_cursor(
			CURSOR[cursor_state]["static"], 
			Input.CURSOR_ARROW, Vector2(0, 0)
		)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT:
		match cursor_state:
			States.DEFAULT:
				if event.is_released():
					Input.set_custom_mouse_cursor(
						CURSOR[cursor_state]["static"], 
						Input.CURSOR_ARROW, Vector2(0, 0)
					)

				if event.is_pressed():
					Input.set_custom_mouse_cursor(
						CURSOR[cursor_state]["active"], 
						Input.CURSOR_ARROW, Vector2(0, 0)
					)

			States.ACTIVE:
				if event.is_pressed():
					Input.set_custom_mouse_cursor(
						CURSOR[cursor_state]["active"],
						Input.CURSOR_ARROW, Vector2(0, 0)
					)

				if event.is_released():
					Input.set_custom_mouse_cursor(
						CURSOR[cursor_state]["static"], 
						Input.CURSOR_ARROW, Vector2(0, 0)
					)
