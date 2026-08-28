extends Node

const ACTIONS:Array[StringName] = ["left", "right", "up", "down", "mwu", "mwd"]
const FILES: Dictionary = {SETTINGS = "user://settings.json"}


func _ready() -> void:
	_setup_input_actions()

func save() -> void:
	pass


func load() -> void:
	pass


func settings_save() -> void:
	var data: String = JSON.stringify(Settings.settings_get(), "\t")
	var file: FileAccess = FileAccess.open(FILES.SETTINGS, FileAccess.WRITE)
	file.store_string(data)


func settings_load() -> void:
	var file: FileAccess = FileAccess.open(FILES.SETTINGS, FileAccess.READ)
	if file && JSON.parse_string(file.get_as_text()):
		Settings.settings_set(JSON.parse_string(file.get_as_text()))
	else:
		Settings.settings_update()


func _setup_input_actions() -> void:
	for action in ACTIONS:
		if !InputMap.has_action(action):
			InputMap.add_action(action)

	var key_left:InputEventKey 			= InputEventKey.new()
	var key_right:InputEventKey 		= InputEventKey.new()
	var key_up:InputEventKey 			= InputEventKey.new()
	var key_down:InputEventKey 			= InputEventKey.new()
	var key_mwu:InputEventMouseButton 	= InputEventMouseButton.new()
	var key_mwd:InputEventMouseButton 	= InputEventMouseButton.new()

	key_left.physical_keycode 	= KEY_A
	key_right.physical_keycode 	= KEY_D
	key_up.physical_keycode 	= KEY_W
	key_down.physical_keycode 	= KEY_S
	key_mwu.button_index		= MOUSE_BUTTON_WHEEL_UP
	key_mwd.button_index		= MOUSE_BUTTON_WHEEL_DOWN

	InputMap.action_add_event(ACTIONS[0], key_left)
	InputMap.action_add_event(ACTIONS[1], key_right)
	InputMap.action_add_event(ACTIONS[2], key_up)
	InputMap.action_add_event(ACTIONS[3], key_down)
	InputMap.action_add_event(ACTIONS[4], key_mwu)
	InputMap.action_add_event(ACTIONS[5], key_mwd)