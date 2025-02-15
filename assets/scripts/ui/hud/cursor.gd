extends Node2D

@onready var main:String = GameData.main
@onready var tooltip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

enum states {DEFAULT}
var state:int = states.DEFAULT
var cursor:Dictionary = {
	"default": {
		"static": load("res://assets/resources/ui/interactive/hud/cursor/cursor_static.png"),
		"active": load("res://assets/resources/ui/interactive/hud/cursor/cursor_active.png"),
	},
}

func _ready():
	if cursor.has("default"):
		if cursor["default"].has("static"):
			Input.set_custom_mouse_cursor(
				cursor["default"]["static"], 
				Input.CURSOR_ARROW, 
				Vector2(0,0)
				)
		else:
			push_error("The 'static' key is missing")
	else:
		push_error("The 'default' group does not exist.")
		
func _input(event) -> void:
	match state:
		states.DEFAULT:
			if cursor.has("default"):
				if cursor["default"].has("active"):
					if event is InputEventMouseButton\
					and event.button_index == MOUSE_BUTTON_LEFT\
					and event.is_pressed():
						Input.set_custom_mouse_cursor(
							cursor["default"]["active"],
							Input.CURSOR_ARROW, 
							Vector2(0,0)
							)
				else:
					push_error("The 'active' key is missing")
					
				if cursor["default"].has("static"):
					if event is InputEventMouseButton\
					and event.button_index == MOUSE_BUTTON_LEFT\
					and event.is_released():
						Input.set_custom_mouse_cursor(
							cursor["default"]["static"],
							Input.CURSOR_ARROW, 
							Vector2(0,0)
							)
				else:
					push_error("The 'static' key is missing")
			else:
				push_error("The 'default' group does not exist.")
		_:
			pass