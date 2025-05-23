extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var container:GridContainer = $Main/VBoxContainer/MarginContainer/MarginContainer/ScrollContainer/GridContainer
@onready var header:Label = $Main/VBoxContainer/Header/Label
@onready var anim:AnimationPlayer = $AnimationPlayer

var sign_name
var opened:bool = false
var items = Items.new()

var items_to_create = []
var current_item_index = 0

func _process(_delta) -> void:
	if visible && (items_to_create.size() > 0 && current_item_index < items_to_create.size()):
		for i in range(1):
			if current_item_index < items_to_create.size():
				_create_item(items_to_create[current_item_index])
				current_item_index += 1
			else:
				break
	else:
		set_process(false)

func _ready():
	_set_header()
	_check_window()
	set_process(false)

func _open(node_name) -> void:
	_create_all_items()
	anim.play("open")
	blur.blur(true)
	opened = true
	pause.other_menu = true
	sign_name = node_name
	_check_window()

func _close() -> void:
	anim.play("close")
	blur.blur(false)
	pause.other_menu = false
	opened = false
	_remove_all_items()

func _set_header() -> void:
	header.text = tr("ui.sign_menu.header")

func _create_item(item_id) -> void:
	var node = inventory.node
	var slot = node.instantiate()
	var item_icon:CompressedTexture2D = items.content[item_id]['icon']
	var item_caption:String = items.content[item_id]['caption']
	container.add_child(slot)
	slot.set_data(
		item_id, 
		1,
		item_icon,
		item_caption
	)

func _create_all_items() -> void:
	current_item_index = 0
	items_to_create = [] 
	for item in items.content:
		if items.content.has(item):
			items_to_create.append(item)
	set_process(true)

func _remove_all_items() -> void:
	for item in container.get_children():
		container.remove_child(item)

func _check_window() -> void:
	visible = opened	

func _on_exit_button_pressed():
	_close()
