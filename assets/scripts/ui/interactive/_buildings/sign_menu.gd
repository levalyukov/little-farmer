extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var container:GridContainer = $Main/VBoxContainer/MarginContainer/ScrollContainer/GridContainer
@onready var header:Label = $Main/VBoxContainer/Header/Label
@onready var anim:AnimationPlayer = $AnimationPlayer

var sign_name
var opened:bool = false
var items = Items.new()

func _ready():
	_set_header()
	_check_window()

func _open(node_name) -> void:
	_create_all_items()
	anim.play("open")
	blur.blur(true)
	opened = true
	pause.other_menu = true
	sign_name = node_name

func _close() -> void:
	_remove_all_items()
	anim.play("close")
	blur.blur(false)
	pause.other_menu = false
	opened = false

func _set_header() -> void:
	var header_:String = tr("signmenu.header")
	header.text = header_ + ":"

func _create_all_items() -> void:
	for item in items.content:
		if items.content.has(item):
			var node = inventory.node
			var slot = node.instantiate()
			container.add_child(slot)
			slot.set_data(item, 1)

func _remove_all_items() -> void:
	for item in container.get_children():
		container.remove_child(item)

func _check_window() -> void:
	visible = opened	

func _on_exit_button_pressed():
	_close()
