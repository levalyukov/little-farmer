extends CanvasLayer

# =============================================================================================
# UIManager (ui.gd)
# =============================================================================================
# Центральный модуль управления пользовательским интерфейсом.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Создание и удаление пользовательского интерфейса
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - ui_add(object) - Добавление пользовательского интерфейса в контейнер UI, если нету
# - ui_remove(object) - Удаление ПИ из контейнера UI
#
# ЗАВИСИМОСТИ:
# - Cursor - Курсор игрока
# - Blur - Размытие фона
# - Blackout - Затемнение экрана для плавного эффекта перехода
#
# =============================================================================================

@onready var cursor: Cursor = $Cursor
@onready var blur: BlurEffect = $Blur
@onready var blackout: BlackoutEffect = $Blackout

var build: BuildManager = null

var ui: Dictionary = {}

const MENUS: Dictionary = {
	PAUSE 	= preload("res://assets/nodes/ui/menu/pause.tscn"),
	OPTIONS = preload("res://assets/nodes/ui/menu/settings.tscn"),
	CREDITS = preload("res://assets/nodes/ui/menu/credits.tscn"),
	
	HUD 	= preload("res://assets/nodes/ui/hud/hud.tscn"),
	BUILD 	= preload("res://assets/nodes/ui/windows/build/build_menu.tscn")
}


func ui_add(object: PackedScene) -> void:
	var node = object.instantiate()
	if !ui.has(node.name):
		ui[node.name] = node
		self.add_child(node)


func ui_remove(node: Control) -> void:
	if !node:
		return

	if ui.has(node.name):
		ui.erase(node.name)
		self.remove_child(node)
		node.queue_free()


func ui_get(node_name: String) -> Control:
	var node: Control = null
	if ui.has(node_name):
		node = ui[node_name]
	return node


func button_pressed() -> void:
	SoundManager.play_sound("ui/click")
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)


func button_hovered(disabled: bool = false) -> void:
	if !disabled:
		SoundManager.play_sound("ui/hover")
		UIManager.cursor.set_cursor(UIManager.cursor.STATES.ACTIVE)


func button_exited() -> void:
	UIManager.cursor.set_cursor(UIManager.cursor.STATES.DEFAULT)
