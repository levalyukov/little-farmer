extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")

@onready var itemsForCompostMargin:MarginContainer = $Panel/VBoxContainer/HBoxContainer/ItemsForCompostMargin
@onready var itemsForCompostContainer:GridContainer = $Panel/VBoxContainer/HBoxContainer/ItemsForCompostMargin/VBoxContainer/ItemContainer/ScrollContainer/GridContainer
@onready var compostingProcessMargin:MarginContainer = $Panel/VBoxContainer/HBoxContainer/ProgressMargin
@onready var compostingProcessLabel:Label = $Panel/VBoxContainer/HBoxContainer/ProgressMargin/VBoxContainer/LabelMargin/Header
@onready var selectItemsLabel:MarginContainer = $Panel/VBoxContainer/SelectItemsMargin
@onready var playerInventoryMargin:MarginContainer = $Panel/VBoxContainer/HBoxContainer/PlayerInventory
@onready var playerInventoryItemsContainer:GridContainer = $Panel/VBoxContainer/HBoxContainer/PlayerInventory/VBoxContainer/ItemContainer/ScrollContainer/GridContainer

@onready var startComposting:Button = $Panel/VBoxContainer/HBoxContainer/ItemsForCompostMargin/VBoxContainer/ButtonMargin/TurnButton
@onready var getCompostButton:Button = $Panel/VBoxContainer/HBoxContainer/ProgressMargin/VBoxContainer/GetCompostMargin/GetCompostButton
@onready var anim:AnimationPlayer = $AnimationPlayer

var current_slot_index: int = 0
var slots_to_create: Array = []

var current_node:Node2D
var items:Object = Items.new()
var opened:bool = false

func _ready():
	close()

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		close()

func _process(_delta) -> void:
	if visible:
		if slots_to_create.size() > 0 and current_slot_index < slots_to_create.size():
			for i in range(1):
				if current_slot_index < slots_to_create.size():
					item_create(slots_to_create[current_slot_index])
					current_slot_index += 1
				else:
					break
		if current_node:
			if current_node.composting:
				if current_node.composting_value < 100.0:
					var formatted_value = "%.2f" % current_node.composting_value
					compostingProcessLabel.text = "Компостирование\n(%s%%)" % formatted_value
					if getCompostButton.visible:
						getCompostButton.visible = false
					if startComposting.visible:
						startComposting.visible = false
				if current_node.composting_value > 100.0:
					current_node.stop_compost()
					current_node.composting_value = 100.0
					compostingProcessLabel.text = "Компост готов"
					if !getCompostButton.visible:
						getCompostButton.visible = true

func add_item_compost(id, amount:int = 1) -> void:
	if visible:
		if current_node:
			if !current_node.compost_items.has(id):
				current_node.compost_items[id] = {}
				if !current_node.compost_items[id].has("amount"):
					current_node.compost_items[id]["amount"] = amount
			else:
				if current_node.compost_items[id]["amount"] + amount <= inventory.inventory_items[id]["amount"]:
					current_node.compost_items[id]["amount"] += amount
			update_compost_items()

func remove_item_compost(id, amount:int = 1) -> void:
	if visible:
		if current_node:
			for item in current_node.compost_items:
				if id == item:
					if current_node.compost_items[id].has("amount"):
						if current_node.compost_items[id]["amount"] == 1:
							current_node.compost_items.erase(id)
						else:
							if amount > 0:
								current_node.compost_items[id]["amount"] -= amount
							else:
								current_node.compost_items[id]["amount"] -= 1
					update_compost_items()

func clear_compost_items() -> void:
	for i in itemsForCompostContainer.get_children():
		itemsForCompostContainer.remove_child(i)

func update_compost_items() -> void:
	if visible:
		if current_node:
			clear_compost_items()
			for i in current_node.compost_items:
				var slot = inventory.node.instantiate()
				itemsForCompostContainer.add_child(slot)
				slot.set_data(i, current_node.compost_items[i]["amount"])
				slot.cmpst_type = 1

func item_create(id) -> void:
	var slot = inventory.node.instantiate()
	if inventory.inventory_items.has(id):
		if inventory.inventory_items[id]["amount"] > 0:
			playerInventoryItemsContainer.add_child(slot)
			slot.set_data(id, inventory.inventory_items[id]["amount"])
			slot.cmpst_type = 0

func get_compost_state() -> void:
	if getCompostButton.visible && current_node.composting_value != 100.0:
		getCompostButton.visible = false
	
func check_state_button() -> void:
	if current_node:
		if !current_node.composting:
			if current_node.composting_value != 100.0:
				if !startComposting.visible:
					startComposting.visible = true
				if itemsForCompostContainer.get_children().size() > 0:
					startComposting.disabled = false
				else:
					startComposting.disabled = true

func get_compost_items() -> void:
	remove_all_inventory_items()
	slots_to_create = []
	for item in inventory.inventory_items:
		if items.content.has(int(item)):
			if items.content[int(item)].has("item_type"):
				if items.content[int(item)]["item_type"] == "compost":
					if inventory.inventory_items[item].has("amount"):
						if inventory.inventory_items[item]["amount"] > 0:
							slots_to_create.append(item)
	current_slot_index = 0

func remove_all_inventory_items() -> void:
	for i in playerInventoryItemsContainer.get_children():
		playerInventoryItemsContainer.remove_child(i)

func open(node:Node2D) -> void:
	node.compost_items = {}
	current_node = node
	opened = true
	blur.blur(true)
	anim.play("open")
	get_compost_state()
	get_compost_items()
	clear_compost_items()
	check_state_button()
	compostingProcessLabel.text = "Выберите отходы для начала компостирования."

func close() -> void:
	opened = false
	blur.blur(false)
	anim.play("close")
	current_node = null

func _check_window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_get_compost_button_pressed() -> void:
	current_node.composting = false
	current_node.composting_value = 0.0
	if inventory:
		inventory.add_item(61, randi_range(1,5))
	if getCompostButton.visible:
		getCompostButton.visible = false
	if !startComposting.visible:
		startComposting.visible = !false
	get_compost_state()
	get_compost_items()
	clear_compost_items()
	check_state_button()
	compostingProcessLabel.text = "Выберите отходы для начала процесса компостирования."

func _on_turn_button_pressed():
	if itemsForCompostContainer.get_children().size() > 0:
		for i in current_node.compost_items:
			inventory.subject_item(i, current_node.compost_items[i]["amount"])
		current_node.composting = true
		current_node.compost_items = {}
		current_node.composting_value = 0.0
		current_node.start_compost(2.5)
		current_node.update()
		get_compost_state()
		get_compost_items()
		clear_compost_items()
		check_state_button()

func _on_button_exit_pressed() -> void:
	close()
