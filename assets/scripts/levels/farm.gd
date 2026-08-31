extends Node2D

@export var cycle: WorldCycle
@export var tilemap: TileMap
@export var build: BuildManager
@export var nature: NatureManager
@export var shadow: ShadowManager


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") && !UIManager.blur.state:
		UIManager.add_ui(UIManager.MENUS.PAUSE)
		UIManager.remove_ui(UIManager.get_ui("HUD"))

	if event.is_action_pressed("tab") && !UIManager.blur.state:
		if UIManager.get_ui("HUD"):
			UIManager.get_ui("HUD").close()
		UIManager.add_ui(UIManager.MENUS.INVENTORY)


func _ready() -> void:
	UIManager.add_ui(UIManager.MENUS.HUD)
	UIManager.blackout.blackout(false)
	tilemap.update_atlas(cycle.season_id)

	nature.spawn()


func _exit_tree() -> void:
	UIManager.remove_ui(UIManager.get_ui("HUD"))
