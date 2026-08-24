extends Node

# ===================================================================
# Settings (settings.gd)
# ===================================================================
# Центральный модуль отвечающий за конфигурацию игры.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Смена локализации игры
# - Настройка графики, уровень звуков и управления
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - settings_update() - Применить все настройки
# - settings_set(values:Dictionary) - Установить значения переменных
# - settings_get() - Вернуть текущие настройки игры в виде словаря
#
# ===================================================================

const MAX_FPS: int = 250
const LANGUAGES_KEYS: Array[String] = ["ru", "en"]

var language: int = 0
var vsync: bool = false
var fullscreen: bool = true
var fps: int = 1

var general_volume: int = 100
var music_volume: int = 25
var nature_volume: int = 50
var radio_volume: int = 75

var movement_type: int = 1


func settings_update() -> void:
	ProjectSettings.set_setting("display/window/vsync/vsync_mode", 1 if vsync else 0)
	get_window().mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
	settings_fps_apply()
	settings_volume_apply()


func settings_set(values: Dictionary) -> void:
	language = int(values["language"]) if values.has("language") else 1
	movement_type = (
		int(values["control"]["movement"]) if values.has("control") && values["control"].has("movement") else 1
	)
	vsync = bool(values["graphic"]["vsync"]) if values.has("graphic") && values["graphic"].has("vsync") else false
	fullscreen = bool(values["graphic"]["screen"]) if values.has("graphic") && values["graphic"].has("screen") else true
	fps = int(values["graphic"]["fps"]) if values.has("graphic") && values["graphic"].has("fps") else 1
	general_volume = (
		int(values["volumes"]["general"]) if values.has("volumes") && values["volumes"].has("general") else 100
	)
	music_volume = int(values["volumes"]["music"]) if values.has("volumes") && values["volumes"].has("music") else 0
	nature_volume = int(values["volumes"]["nature"]) if values.has("volumes") && values["volumes"].has("nature") else 50
	radio_volume = int(values["volumes"]["radio"]) if values.has("volumes") && values["volumes"].has("radio") else 75

	settings_update()


func settings_fps_apply() -> void:
	match fps:
		0:
			Engine.max_fps = 30
		1:
			Engine.max_fps = 60
		_:
			Engine.max_fps = self.MAX_FPS


func settings_volume_apply() -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), 20.0 * log(clamp(general_volume / 100.0, 0.001, 1.0)) / log(10.0)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"), 20.0 * log(clamp(music_volume / 100.0, 0.001, 1.0)) / log(10.0)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Nature"), 20.0 * log(clamp(nature_volume / 100.0, 0.001, 1.0)) / log(10.0)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Radio"), 20.0 * log(clamp(radio_volume / 100.0, 0.001, 1.0)) / log(10.0)
	)


func settings_get() -> Dictionary:
	return {
		"language": language,
		"graphic": {"vsync": vsync, "screen": fullscreen, "fps": fps},
		"volumes": {"general": general_volume, "music": music_volume, "nature": nature_volume, "radio": radio_volume},
		"control": {"movement": movement_type}
	}
