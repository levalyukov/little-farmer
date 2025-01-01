extends Control

@onready var container:VBoxContainer = $MarginContainer/VBoxContainer
@onready var node:PackedScene = load("res://assets/nodes/ui/feedback/notifications/notice.tscn")

const maximum:int = 32

func create_notice(text:String, type = "") -> void:
	var notice = node.instantiate()
	if container.get_children().size() < maximum:
		if text != "":
			container.add_child(notice)
			notice.notice(text, type)
