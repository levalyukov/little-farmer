extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var margin:MarginContainer = $Main
@onready var icon:TextureRect = $Main/Content/HBoxContainer/MarginIcon/Icon
@onready var label:Label = $Main/Content/HBoxContainer/MarginLabel/Label
@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var time:Timer = $Timer

const symbols:int = 30
var icons:Dictionary = {
	"error" = load("res://assets/resources/ui/feedback/notifications/icons/error.png"),
	"photo" = load("res://assets/resources/ui/feedback/notifications/icons/photo.png"),
}

func notice(text:String, type = "") -> void:
	set_text(text)
	set_icon(type)
	anim.play("create")
	await get_tree().create_timer(0.01).timeout
	custom_minimum_size.y = margin.size.y

func set_text(text:String) -> void:
	visible = true
	label.text = text

func set_icon(type) -> void:
	if type in icons:
		icon.texture = icons[type]
	else:
		if type is CompressedTexture2D:
			icon.texture = type

func _on_timer_timeout() -> void:
	anim.play("delete")

func notice_delete() -> void:
	queue_free()
