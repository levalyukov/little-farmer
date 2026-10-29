class_name MMWindows extends Control

@onready var container: HBoxContainer = $HBox

enum MenuWindows { NONE, SETTINGS, CREDITS, NEWS }
var windows_ref: Dictionary = {
	MenuWindows.SETTINGS: preload("res://assets/nodes/ui/menu/settings.tscn"),
	MenuWindows.CREDITS: preload("res://assets/nodes/ui/menu/credits.tscn"),
	MenuWindows.NEWS: preload("res://assets/nodes/ui/menu/news.tscn")
}

var windows: Dictionary = {}
var current_window: MenuWindows = MenuWindows.NONE


func open_window(window: MenuWindows) -> void:
	if !windows.has(window) && container.get_children().size() < 2:
		var node: Node = windows_ref[window].instantiate()
		if node != null && node is Control:
			node.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
			windows[window] = node
			container.add_child(node)
			current_window = window
	else:
		if current_window != window:
			close_window(current_window)
			open_window(window)


func close_window(window: MenuWindows) -> void:
	if windows.has(window):
		current_window = MenuWindows.NONE
		container.remove_child(windows[window])
		windows.erase(window)
