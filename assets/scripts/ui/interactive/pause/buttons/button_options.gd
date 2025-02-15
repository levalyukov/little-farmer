extends Button

@onready var main_scene = GameData.main
@onready var blur:Control = get_node("/root/" + main_scene + "/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/" + main_scene + "/UI/Interactive/Pause")
@onready var options:Control = get_node("/root/" + main_scene + "/UI/Interactive/Options")
@onready var player:CharacterBody2D = get_node("/root/" + main_scene + "/Camera")

func _on_pressed() -> void:
	if blur.state:
		if pause.paused:
			options.open()
			pause.visible = false
