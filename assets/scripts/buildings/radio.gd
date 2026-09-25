extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: Area2D = $Area2D


func _ready() -> void:
	if collision:
		collision.mouse_entered.connect(
			func() -> void:
				if UIManager.get_ui("HUD") && sprite.material:
					sprite.material.set_shader_parameter("highligth", true)
		)

		collision.mouse_exited.connect(
			func() -> void:
				if UIManager.get_ui("HUD") && sprite.material:
					sprite.material.set_shader_parameter("highligth", false)
		)
