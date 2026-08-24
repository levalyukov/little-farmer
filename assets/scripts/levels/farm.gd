extends Node2D

@export var time: WorldCycle
@export var tilemap: TileMap
@export var build: BuildManager
@export var nature: NatureManager
@export var shadow: ShadowManager


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") && !UIManager.blur.state:
		UIManager.ui_add(UIManager.MENUS.PAUSE)
		UIManager.ui_remove(UIManager.ui_get("HUD"))

	if event.is_action_pressed("tab") && !UIManager.blur.state:
		UIManager.ui_get("HUD")._close()
		UIManager.ui_add(UIManager.MENUS.INVENTORY)


func _ready() -> void:
	UIManager.ui_add(UIManager.MENUS.HUD)
	UIManager.blackout.blackout(false)
	tilemap.update_atlas(time.season_id)


func _exit_tree() -> void:
	UIManager.ui_remove(UIManager.ui_get("HUD"))
