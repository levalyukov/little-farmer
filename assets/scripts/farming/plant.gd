extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var indicator: Sprite2D = $Indicator
@onready var collision: Area2D = $Area2D
@onready var anim: AnimationPlayer = $Animation

var id: int = 0
var level: int = 0
var max_level: int = -1
var growed: bool = false


func _ready() -> void:
	if collision:
		collision.input_pickable = true
		collision.mouse_entered.connect(
			func() -> void:
				if sprite.material:
					var build: BuildManager = get_tree().current_scene.build

					if (
						build
						&& build.buildings.has("Grid")
						&& growed
						&& build.buildings["Grid"].mode == BuildManager.GridModes.HARVESTING
					):
						sprite.material.set_shader_parameter("success", true)
						sprite.material.set_shader_parameter("highligth", true)

					if !(build && build.buildings.has("Grid")):
						sprite.material.set_shader_parameter("success", false)
						sprite.material.set_shader_parameter("destroy", false)
						sprite.material.set_shader_parameter("highligth", true)
		)

		collision.mouse_exited.connect(
			func() -> void:
				if sprite.material:
					sprite.material.set_shader_parameter("destroy", false)
					sprite.material.set_shader_parameter("highligth", false)
		)


func update() -> void:
	if !sprite:
		return

	level = clamp(level + 1, 1, max_level)
	sprite.region_rect.position.x = level * Crops.SIZE.x
