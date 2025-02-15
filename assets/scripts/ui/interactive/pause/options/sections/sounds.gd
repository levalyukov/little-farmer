extends Control

@onready var main_scene = GameData.main
@onready var options:Control = get_node("/root/" + main_scene + "/UI/Interactive/Options")
@onready var label:Label = $MarginContainer/Label
@onready var page:PackedScene = load("res://assets/nodes/ui/pause/options/sections/pages/sounds.tscn")

func set_text(text:String) -> void:
	label.text = text
	
func set_page(scene:PackedScene) -> void:
	self.page = scene

func _on_button_pressed():
	if options.menu:
		if (page != null and typeof(page) == TYPE_OBJECT):
			options.page(page)
