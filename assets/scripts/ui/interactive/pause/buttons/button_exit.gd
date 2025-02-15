extends Button

@onready var main = GameData.main
@onready var data = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")

func _on_pressed() -> void:
	if blur.state:
		if pause.paused:
			blackout.blackout(true)
			if main == "Farm":
				data.gamesave()
			blackout.change_scene("res://levels/menu.tscn")
