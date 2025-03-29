extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tooltip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

enum states {DEFAULT, EXPLORE, ACTIVE}
var state:int = states.DEFAULT
var cursor:Dictionary = {
	"default": {
		"static": load("res://assets/resources/ui/interactive/hud/cursor/cursor_static.png"),
		"active": load("res://assets/resources/ui/interactive/hud/cursor/cursor_active.png"),
	},
	"explore": {
		"static": load("res://assets/resources/ui/interactive/hud/cursor/explore.png"),
	},
	'active': {
		"static": load("res://assets/resources/ui/interactive/hud/cursor/clicked_default.png"),
		"active": load("res://assets/resources/ui/interactive/hud/cursor/clicked_active.png"),
	}
}

func _ready():
	set_cursor(state)

func set_cursor(cursorState:int) -> void:
	state = cursorState
	match cursorState:
		states.DEFAULT:
			if cursor.has("default"):
				if cursor["default"].has("static"):
					Input.set_custom_mouse_cursor(
						cursor["default"]["static"], 
						Input.CURSOR_ARROW, 
						Vector2(0,0)
						)
		states.EXPLORE:
			if cursor.has("explore"):
				if cursor["explore"].has("static"):
					Input.set_custom_mouse_cursor(
						cursor["explore"]["static"],
						Input.CURSOR_ARROW, 
						Vector2(0,0)
						)
		states.ACTIVE:
			if cursor.has("active"):
				if cursor["active"].has("static"):
					Input.set_custom_mouse_cursor(
						cursor["active"]["static"],
						Input.CURSOR_ARROW, 
						Vector2(0,0)
						)

func _input(event) -> void:
	match state:
		states.DEFAULT:
			if cursor.has("default"):
				if cursor["default"].has("active"):
					if event is InputEventMouseButton\
					&& event.button_index == MOUSE_BUTTON_LEFT\
					&& event.is_pressed():
						Input.set_custom_mouse_cursor(
							cursor["default"]["active"],
							Input.CURSOR_ARROW, 
							Vector2(0,0)
							)
				if cursor["default"].has("static"):
					if event is InputEventMouseButton\
					&& event.button_index == MOUSE_BUTTON_LEFT\
					&& event.is_released():
						Input.set_custom_mouse_cursor(
							cursor["default"]["static"],
							Input.CURSOR_ARROW, 
							Vector2(0,0)
							)
		states.EXPLORE:
			if cursor.has("explore"):
				if cursor["explore"].has("static"):
					Input.set_custom_mouse_cursor(
						cursor["explore"]["static"],
						Input.CURSOR_ARROW, 
						Vector2(0,0)
						)
		states.ACTIVE:
			if cursor.has("active"):
				if cursor["active"].has("active"):
					if event is InputEventMouseButton\
					&& event.button_index == MOUSE_BUTTON_LEFT\
					&& event.is_pressed():
						Input.set_custom_mouse_cursor(
							cursor["active"]["active"],
							Input.CURSOR_ARROW, 
							Vector2(0,0)
							)
				if cursor["active"].has("static"):
					if event is InputEventMouseButton\
					&& event.button_index == MOUSE_BUTTON_LEFT\
					&& event.is_released():
						Input.set_custom_mouse_cursor(
							cursor["active"]["static"],
							Input.CURSOR_ARROW, 
							Vector2(0,0)
							)
		_:
			pass