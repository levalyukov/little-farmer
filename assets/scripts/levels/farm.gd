extends Node2D

@export var build: BuildManager
@export var tilemap : TileMap

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") && !UIManager.blur.state:
		UIManager.ui_add(UIManager.MENUS.PAUSE)
		UIManager.ui_remove(UIManager.ui_get("HUD"))

func _ready() -> void:
	UIManager.build = self.build
	UIManager.ui_add(UIManager.MENUS.HUD)
	UIManager.blackout.blackout(false)

func _exit_tree() -> void:
	UIManager.ui_remove(UIManager.ui_get("HUD"))
