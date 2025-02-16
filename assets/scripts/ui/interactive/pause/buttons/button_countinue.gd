extends Button

@onready var main = str(get_tree().root.get_child(2).name)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")

func _on_pressed() -> void:
	if blur.state:
		if pause.paused:
			pause.close()
			player.check_switch()
