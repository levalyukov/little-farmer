extends Node2D

@onready var cycle: WorldCycle = get_tree().current_scene.cycle
@onready var build: BuildManager = get_tree().current_scene.build
@onready var collision: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

const TEXTURES: Dictionary = {
	WorldCycle.Season.SPRING: preload("res://assets/resources/buildings/stall/spring.png"),
	WorldCycle.Season.SUMMER: preload("res://assets/resources/buildings/stall/summer.png"),
	WorldCycle.Season.AUTUMN: preload("res://assets/resources/buildings/stall/autumn.png"),
	WorldCycle.Season.WINTER: preload("res://assets/resources/buildings/stall/winter.png")
}


func _ready() -> void:
	if !is_instance_valid(cycle):
		printerr("WorldCycle node is NULL.")
		return

	if !is_instance_valid(build):
		printerr("BuildManager node is NULL.")
		return

	if !TEXTURES.is_empty() && sprite:
		sprite.texture = TEXTURES[cycle.season]

	if collision:
		collision.mouse_entered.connect(
			func() -> void:
				if sprite.material:
					sprite.material.set_shader_parameter(
						"destroy",
						build.buildings.has("Grid") && build.buildings["Grid"].mode == BuildManager.GridModes.DESTROY
					)
					sprite.material.set_shader_parameter(
						"highligth",
						(
							(
								build.buildings.has("Grid")
								&& build.buildings["Grid"].mode == BuildManager.GridModes.DESTROY
							)
							|| UIManager.get_ui("HUD")
						)
					)
		)

		collision.mouse_exited.connect(
			func() -> void:
				if sprite.material:
					sprite.material.set_shader_parameter("destroy", false)
					sprite.material.set_shader_parameter("highligth", false)
		)
