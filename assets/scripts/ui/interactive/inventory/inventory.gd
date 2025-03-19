extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var tools:HBoxContainer = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Tools")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var node:PackedScene = load("res://assets/nodes/ui/interactive/inventory/slot.tscn")

@onready var anim:AnimationPlayer = $Animation
@onready var info:BoxContainer = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer
@onready var scroll_info:ScrollContainer = $Main/HBoxContainer/ItemContent/ScrollContainer
@onready var slots:GridContainer = $Main/HBoxContainer/InventoryContent/Panel/MarginContainer/ScrollContainer/MarginContainer/GridContainer
@onready var scroll_slots:ScrollContainer = $Main/HBoxContainer/InventoryContent/ScrollContainer

@onready var icon:TextureRect = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/ItemIconContainer/TextureRect
@onready var caption:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/HeaderContainer/Header
@onready var description:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/ContentContainer/Content
@onready var specifications_margin:MarginContainer = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/Specifications
@onready var specifications:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/Specifications/Specifications
@onready var type:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/Type/Type
@onready var button:Button = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/ButtonContainer/Button
@onready var list:Label = $Main/HBoxContainer/InventoryContent/Label

var item = Items.new()
var crops = Crops.new()
var audio = AudioStreamPlayer.new()

var current_slot_index:int = 0
var slots_to_create:Array = []
var opened:bool = false
var item_index
var button_index:int
var inventory_items:Dictionary = {
	1:{"amount":1000},
	2:{"amount":1000},
	3:{"amount":1000},
	4:{"amount":1000},
	5:{"amount":1000},
	6:{"amount":1000},
	7:{"amount":1000},
	8:{"amount":1000},
	9:{"amount":1000},
	10:{"amount":1000},
	11:{"amount":1000},
	12:{"amount":1000},
	13:{"amount":1000},
	14:{"amount":1000},
	15:{"amount":1000},
	16:{"amount":1000},
	17:{"amount":1000},
	18:{"amount":1000},
	19:{"amount":1000},
	20:{"amount":1000},
	21:{"amount":1000},
	22:{"amount":1000},
	23:{"amount":1000},
	24:{"amount":1000},
	25:{"amount":1000},
	26:{"amount":1000},
	27:{"amount":1000},
	28:{"amount":1000},
	29:{"amount":1000},
	30:{"amount":1000},
	31:{"amount":1000},
	32:{"amount":1000},
	33:{"amount":1000},
	34:{"amount":1000},
	35:{"amount":1000},
	36:{"amount":1000},
	37:{"amount":1000},
	38:{"amount":1000},
	39:{"amount":1000},
	40:{"amount":1000},
	41:{"amount":1000},
	42:{"amount":1000},
	43:{"amount":1000},
	44:{"amount":1000},
	45:{"amount":1000},
	46:{"amount":1000},
	47:{"amount":1000},
	48:{"amount":1000},
	49:{"amount":1000},
	50:{"amount":1000},
	51:{"amount":1000},
	52:{"amount":1000},
	53:{"amount":1000},
	54:{"amount":1000},
	55:{"amount":1000},
	56:{"amount":1000},
	57:{"amount":1000},
	58:{"amount":1000},
	59:{"amount":1000},
	60:{"amount":1000},
	61:{"amount":1000},
	62:{"amount":1000},
}
enum item_type {NOTHING, SEEDS, FERTILIZER}

func _ready():
	check_window()
	reset_data()
	self.add_child(audio)

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		close()

	if Input.is_action_just_pressed("tab"):
		if !blur.state\
		&& !pause.paused\
		&& !pause.other_menu\
		&& !opened:
			open()
		else:
			if opened:
				close()

func inventory_update():
	var remove_items = []
	for id in inventory_items:
		if inventory_items[id]["amount"] == 0:
			remove_items.append(id)
	
	if remove_items != []:
		for i in remove_items:
			inventory_items.erase(i)

func check_inventory():
	if has_node("/root/"+main+"/ConstructionManager/storage"):
		var max_slots = storage.object[storage.level]["slots"]
		while inventory_items.size() > max_slots:
			for id in inventory_items:
				inventory_items.erase(id)
				break
				data.debug("Due to inventory overflow, an item with the following ID was destroyed: " + str(id), "info")

func load_content(content:Dictionary) -> void:
	inventory_items = content

func open() -> void:
	opened = true
	pause.other_menu = true
	blur.blur(true)
	anim.play("open")
	inventory_update()
	check_inventory()
	if grid.mode != grid.modes.NOTHING:
		grid.mode = grid.modes.NOTHING
	if audio:
		if !audio.is_playing():
			audio.stream = load('res://assets/sounds/ui/inventory.ogg')
			audio.play()
	create_all_items()
	update_string_capacity()

func close() -> void:
	opened = false
	blur.blur(false)
	anim.play("close")
	remove_inventory_slots()

func get_data(index) -> void:
	if opened:
		self.item_index = index
		scroll_info.scroll_vertical = 0
		if item.content.has(int(index)):
			if item.content[int(index)].has("icon"):
				if typeof(item.content[int(index)]["icon"]) == TYPE_OBJECT:
					icon.visible = true
					icon.texture = item.content[int(index)]["icon"]
				else:
					icon.visible = false
					data.debug("[ID: "+str(index)+"] The key stores a non-Compressed 2D Texture.", "error")
			else:
				data.debug("[ID: "+str(index)+"] The object does not have the 'icon' key.", "error")
				icon.visible = false

			if item.content[int(index)].has("caption"):
				if typeof(item.content[int(index)]["caption"]) == TYPE_STRING:
					caption.visible = true
					caption.text = item.content[int(index)]["caption"]
				else:
					caption.visible = false
					data.debug("[ID: "+str(index)+"] The 'caption' key has a non-string type.", "error")
			else:
				data.debug("[ID: "+str(index)+"] The object does not have the 'caption' key.", "error")
				caption.visible = false

			if item.content[int(index)].has("description"):
				if typeof(item.content[int(index)]["description"]) == TYPE_STRING:
					description.visible = true
					description.text = item.content[int(index)]["description"]
				else:
					description.visible = false
					data.debug("[ID: "+str(index)+"] The 'description' key has a non-string type.", "error")
			else:
				description.visible = false
				data.debug("[ID: "+str(index)+"] The object does not have the 'description' key.", "error")

			if item.content[int(index)].has("specifications"):
				if item.content[int(index)].get("specifications") != {}:
					specifications_margin.visible = true
					specifications.text = ""
					for i in item.content[int(index)]["specifications"]:
						get_specifications(int(index), i)
				else:
					specifications_margin.visible = false
					data.debug("[ID: "+str(index)+"] The 'specifications' key is empty.", "error")
			else:
				specifications_margin.visible = false

			if item.content[int(index)].has("type"):
				if typeof(item.content[int(index)]["type"]) == TYPE_STRING:
					var type_text = tr("Тип предмета")
					type.visible = true
					type.text = "\n" + type_text + ": " + item.content[int(index)]["type"] + "\n"
					check_item_type(item.content[int(index)]["item_type"])
					if inventory_items[index]["amount"] > item.maximum:
						var total_amount = tr("Всего")
						type.text += "\n" + total_amount + ": " + str(
							balance.format(inventory_items[index]["amount"])
						)
				else:
					type.visible = false
					data.debug("[ID: "+str(index)+"] The 'type' key has a non-string type.", "error")
			else:
				data.debug("The object does not have the 'type' key.", "error")
		else:
			data.debug("The object does not have the 'type' key.", "error")

func reset_data() -> void:
	icon.visible = false
	caption.visible = false
	description.visible = false
	specifications.visible = false
	type.visible = false
	list.visible = false
	button.visible = false

func get_items() -> Dictionary:
	return inventory_items

func create_all_items() -> void:
	remove_inventory_slots()
	slots_to_create = []
	var items = Items.new()
	for id in inventory_items:
		if items.content.has(int(id)):
			if inventory_items[id].has("amount"):
				if inventory_items[id]["amount"] > 0:
					slots_to_create.append(id)
	current_slot_index = 0

func _process(_delta) -> void:
	if visible:
		if slots_to_create.size() > 0 and current_slot_index < slots_to_create.size():
			for i in range(1):
				if current_slot_index < slots_to_create.size():
					item_create(slots_to_create[current_slot_index])
					current_slot_index += 1
				else:
					break

func remove_inventory_slots() -> void:
	for items in slots.get_children():
		slots.remove_child(items)
		items.queue_free()

func item_create(id) -> void:
	if slots.get_child_count() >= storage.object[storage.level]["slots"]:
		data.debug("Inventory is full. Cannot add more items.", "warning")
		return

	var slot = node.instantiate()
	check_amount(id)
	if inventory_items.has(id):
		if inventory_items[id]["amount"] > 0:
			slots.add_child(slot)
			slot.set_data(id, inventory_items[id]["amount"])
		else:
			remove_item(id)
			data.debug("Invalid item index: " + str(id), "error")

func update_string_capacity() -> void:
	if has_node("/root/"+main+"/ConstructionManager"):
		if has_node("/root/"+main+"/ConstructionManager/storage"):
			if storage.object.has(storage.level) && storage.object[storage.level].has("slots"):
				var text = tr("Доступно слотов")
				list.text = text + ": " + str(get_all_items()) + "/" + str(storage.object[storage.level]["slots"])
				list.visible = true
			else:
				data.debug("The 'slots' element does not exist.", "error")
				list.visible = false
		else:
			data.debug("In the parent of 'ConstructionManager' there is no child node 'Storage'", "error")
	else:
		data.debug("There is no parent of 'ConstructionManager' in the '"+main+"' scene", "error")

func get_all_items() -> int:
	var items = Items.new()
	if slots:
		var item_count:int = 0
		if inventory_items != {}:
			for i in inventory_items:
				if items.content.has(int(i)):
					item_count += 1
		return item_count
	else:
		data.debug("Cannot load parent.", "error")
		return 0

func add_item(id, amount:int = 1) -> void:
	if inventory_items.has(int(id)):
		inventory_items[int(id)]["amount"] += amount
	elif inventory_items.has(str(id)):
		inventory_items[str(id)]["amount"] += amount
	else:
		inventory_items[int(id)] = {"amount": amount}
		
func subject_item(id, item_amount:int = 1) -> void:
	if id is int || id is String:
		if item_amount != 0:
			for key in inventory_items:
				if id is int:
					if id == int(key):
						inventory_items[id]["amount"] -= item_amount 
						check_amount(id)
				elif id is String:
					if id == str(key):
						inventory_items[id]["amount"] -= item_amount 
						check_amount(id)

	if id is Dictionary:
		var resources_id = []
		var amounts = []
		for items in id:
			if id[items].has("amount"):
				if id[items]["amount"] > 0:
					resources_id.append(items)
					amounts.append(id[items]["amount"])

		for idx in range(resources_id.size()):
			var ids = resources_id[idx]
			var amount = amounts[idx]
			if inventory_items.has(int(ids)):
				check_amount(int(ids))
				inventory_items[int(ids)]["amount"] -= amount
			elif inventory_items.has(str(ids)):
				check_amount(str(ids))
				inventory_items[str(ids)]["amount"] -= amount

func remove_item(id) -> void:
	if inventory_items.has(int(id)):
		inventory_items.erase(int(id))
	elif inventory_items.has(str(id)):
		inventory_items.erase(str(id))

func get_item_amount(item_id) -> int:
	if inventory_items.has(int(item_id)):
		if inventory_items[int(item_id)].has("amount"):
			if inventory_items[int(item_id)]["amount"] > 0:
				return inventory_items[int(item_id)]["amount"]
	elif inventory_items.has(str(item_id)):
		if inventory_items[str(item_id)].has("amount"):
			if inventory_items[str(item_id)]["amount"] > 0:
				return inventory_items[str(item_id)]["amount"]
	return 0

func check_item_amount(id) -> bool:
	if inventory_items.has(id):
		if inventory_items[id].has("amount"):
			if inventory_items[id]["amount"] > 0:
				return true
			else:
				remove_item(id)
				return false
	return false

func check_amount(index) -> void:
	if inventory_items.has(index):
		if inventory_items[index].has("amount"):
			if inventory_items[index]["amount"] <= 0:
				remove_item(index)
		else:
			push_warning("[ID: " + str(index) + "] The 'amount' element does not exist in the inventory dictionary (array).")
			inventory_items[index]["amount"] = 1

func get_specifications(index, i) -> void:
	var items = Items.new()
	if typeof(items.content[index]["specifications"][i]) == TYPE_STRING and specifications.text is String:
		specifications.text = specifications.text + "\n• " + get_tip(i) + ": "+ items.content[index]["specifications"][i]
	else:
		data.debug("[ID: "+str(index)+"] The '"+ str(i) +"' element is not a string.", "error")

func update_inventory_content() -> void:
	for items in inventory_items:
		check_amount(items)

func get_tip(tip:String) -> String:
	match tip:
		"growth":
			return tr("Время роста")
		"productivity":
			return tr("Урожайность")
		"conditions":
			return tr("Условия")
		_:
			return ""

func check_item_type(i_type:String) -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		match i_type:
			"seeds":
				button_index = item_type.SEEDS
				button.visible = true
				if item.content[int(item_index)].has('crop'):
					var crop = item.content[int(item_index)]['crop']
					var crop_season = crops.crops[crop]['season']
					for i in crop_season:
						if main == "Farm":
							if i == clock.get_season():
								button.text = tr("Посадить семена")
								button.disabled = false
								break
							else:
								button.text = tr("Не тот сезон")
								button.disabled = !false
								break
						else:
							if main == "Greenhouse":
								button.text = tr("Посадить семена")
								button.disabled = false
								break
			"fertilizer":
				button_index = item_type.FERTILIZER
				button.visible = true
				button.text = tr("Удобрить")
				button.disabled = false
			_:
				button_index = item_type.NOTHING
				button.visible = false

func _on_button_pressed():
	var items = Items.new().content
	var _audio = AudioStreamPlayer.new()
	self.add_child(_audio)
	_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
	_audio.stream = load('res://assets/sounds/ui/click.ogg')
	_audio.play()
	match button_index:
		item_type.SEEDS:
			close()
			if items.has(int(item_index)):
				if items[int(item_index)].has("crop"):
					grid.generate_grid()
					grid.grid_dimensions = tools.features["planting"][tools.planting]["grid_dimensions"]
					grid.inventory_item = item_index
					grid.plantID = items[int(item_index)]["crop"]
					grid.mode = grid.modes.PLANTING
					grid.visible = true
				else:
					data.debug("The 'crop' key does not exist", "error")
			else:
				data.debug("The numerical ID (" + item_index + ") of this crop is missing in the main file crops.gd", "error")
		item_type.FERTILIZER:
			close()
			grid.generate_grid()
			grid.grid_dimensions = tools.features["planting"][tools.planting]["grid_dimensions"]
			grid.inventory_item = item_index
			grid.mode = grid.modes.FERTILIZER
			grid.visible = true
		_:
			pass

func check_window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_close_pressed():
	if opened:
		close()
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/click.ogg')
		_audio.play()

func _on_close_mouse_entered():
	if opened:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/hover.ogg')
		_audio.play()

func _on_button_mouse_entered():
	if visible:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/hover.ogg')
		_audio.play()

func _on_audio_finished(_audio) -> void:
	_audio.queue_free()