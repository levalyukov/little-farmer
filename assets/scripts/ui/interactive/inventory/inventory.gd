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
@onready var node:PackedScene = preload("res://assets/nodes/ui/interactive/inventory/slot.tscn")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")

@onready var anim:AnimationPlayer = $Animation
@onready var info:BoxContainer = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer
@onready var scroll_info:ScrollContainer = $Main/HBoxContainer/ItemContent/ScrollContainer
@onready var slots:GridContainer = $Main/HBoxContainer/InventoryContent/Panel/MarginContainer/ScrollContainer/MarginContainer/GridContainer

@onready var icon:TextureRect = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/ItemIconContainer/TextureRect
@onready var caption:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/HeaderContainer/Header
@onready var description:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/ContentContainer/Content
@onready var specifications_margin:MarginContainer = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/Specifications
@onready var specifications:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/Specifications/Specifications
@onready var type:Label = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/Type/Type
@onready var button:Button = $Main/HBoxContainer/ItemContent/ScrollContainer/VBoxContainer/ButtonContainer/Button
@onready var list:Label = $Main/HBoxContainer/InventoryContent/Label

var inventory_sound = preload('res://assets/sounds/ui/inventory.ogg')

var item = Items.new()
var crops = Crops.new()
var audio = AudioStreamPlayer.new()

var current_slot_index:int = 0
var slots_to_create:Array = []
var opened:bool = false
var item_index
var button_index:int
var inventory_items:Dictionary = {}
enum item_type {NOTHING, SEEDS, FERTILIZER}

func _ready():
	set_process(false)
	check_window()
	reset_data()
	self.add_child(audio)

	var test_index = 0
	while inventory_items.size() < 100:
		test_index += 1
		inventory_items[str(test_index)] = {}
		inventory_items[str(test_index)]['amount'] = 1000
	test_index = 0

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

func load_content(content:Dictionary) -> void:
	inventory_items = content

func open() -> void:
	opened = true
	pause.other_menu = true
	blur.blur(true)
	anim.play("open")
	inventory_update()
	check_inventory()
	create_all_items()
	update_string_capacity()
	if grid.mode != grid.modes.NOTHING: 
		grid.mode = grid.modes.NOTHING
		grid.disabled_grid()
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if audio:
		if !audio.is_playing():
			audio.stream = inventory_sound
			audio.play()
	if tip: tip.tooltip()
	check_window()

func close() -> void:
	opened = false
	blur.blur(false)
	anim.play("close")
	remove_inventory_slots()
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func get_data(index) -> void:
	if opened:
		self.item_index = index
		scroll_info.scroll_vertical = 0
		if item.content.has(int(index)):
			if item.content[int(index)].has("icon"):
				var item_icon = item.content[int(index)]["icon"]
				if item_icon is CompressedTexture2D:
					icon.visible = true
					icon.texture = item_icon
				else:
					icon.visible = false
					data.debug("[ID: "+str(index)+"] The key stores a non-Compressed 2D Texture.", "error")
			else:
				data.debug("[ID: "+str(index)+"] The object does not have the 'icon' key.", "error")
				icon.visible = false

			if item.content[int(index)].has("caption"):
				var item_caption = item.content[int(index)]["caption"]
				if item_caption is String:
					caption.visible = true
					caption.text = tr(item_caption)
				else:
					caption.visible = false
					data.debug("[ID: "+str(index)+"] The 'caption' key has a non-string type.", "error")
			else:
				data.debug("[ID: "+str(index)+"] The object does not have the 'caption' key.", "error")
				caption.visible = false

			if item.content[int(index)].has("description"):
				var item_description = item.content[int(index)]["description"]
				if item_description is String:
					description.visible = true
					if !tr(item_description).ends_with('.'):
						description.text = tr(item_description) + '.'
					else:
						description.text = tr(item_description)

			#	if item.content[int(index)].has("specifications"):
			#		if item.content[int(index)].get("specifications") != {}:
			#			specifications_margin.visible = true
			#			specifications.text = ""
			#			for i in item.content[int(index)]["specifications"]:
			#				get_specifications(int(index), i)
			#		else:
			#			specifications_margin.visible = false
			#			data.debug("[ID: "+str(index)+"] The 'specifications' key is empty.", "error")
			#	else:
			#		specifications_margin.visible = false

			if item.content[int(index)].has("type"):
				if item.content[int(index)]["type"] is Array:
					type.visible = true
					var item_types = item.content[int(index)]["type"]
					
					type.text = "\n" + tr("inventory.tip.item_type") + ": "

					var index_str:int = 0
					for i in item_types:
						index_str += 1
						type.text += tr(str(i))
						if index_str == item_types.size()-1:
							type.text += ', '
					type.text += '\n'
					index_str = 0
					
					check_item_type(item.content[int(index)]["item_type"])

					if inventory_items[index]["amount"] > item.maximum:
						type.text += "\n" + tr("inventory.tip.total_items") + ": " + str(
							balance.format(inventory_items[index]["amount"])
						)
				else:
					type.visible = false

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
	for id in inventory_items:
		if item.content.has(int(id)):
			if inventory_items[id].has("amount"):
				if inventory_items[id]["amount"] > 0:
					slots_to_create.append(id)
	current_slot_index = 0
	set_process(true)

func _process(_delta) -> void:
	if visible && (slots_to_create.size() > 0 && current_slot_index < slots_to_create.size()):
		for i in range(1):
			if current_slot_index < slots_to_create.size():
				item_create(slots_to_create[current_slot_index])
				current_slot_index += 1
			else:
				break
	else:
		set_process(false)

func remove_inventory_slots() -> void:
	slots_to_create.clear()
	for items in slots.get_children():
		slots.remove_child(items)
		items.queue_free()

func item_create(id) -> void:
	check_amount(id)
	var slot_node = node.instantiate()
	var item_caption = item.content[int(id)]["caption"]
	var item_amount = inventory_items[id]["amount"]
	var item_icon = item.content[int(id)]['icon']
	if inventory_items.has(id) && item_amount > 0:
		if slots.get_child_count() < storage.object[storage.level]["slots"]:
			slots.add_child(slot_node)
			slot_node.set_data(
				id, 
				item_amount, 
				item_icon, 
				item_caption
			)
	while slots.get_child_count() > storage.object[storage.level]["slots"]:
		var last_slot = slots.get_children()[-1]
		slots.remove_child(last_slot)
		last_slot.queue_free()

func update_string_capacity() -> void:
	if storage && storage.object.has(storage.level) && storage.object[storage.level].has("slots"):
		list.text = tr("inventory.available_slots") + ": " + str(get_all_items()) + "/" + str(storage.object[storage.level]["slots"])
		list.visible = true

func get_all_items() -> int:
	var item_count:int = 0
	if slots:
		if inventory_items != {}:
			for i in inventory_items:
				if item.content.has(int(i)):
					item_count += 1
	return item_count

func add_item(id, amount:int = 1) -> void:
	if item.content.has(int(id)):
		if inventory_items.has(int(id)):
			inventory_items[int(id)]["amount"] += amount
		elif inventory_items.has(str(id)):
			inventory_items[str(id)]["amount"] += amount
		else:
			inventory_items[int(id)] = {"amount": amount}
		
func subject_item(id, item_amount:int = 1) -> void:
	if inventory_items.has(int(id)):
		if item_amount > 0:
			check_amount(int(id))
			var inventory = inventory_items[int(id)]
			inventory["amount"] -= item_amount 

	if inventory_items.has(str(id)):
		if item_amount > 0:
			check_amount(str(id))
			var inventory = inventory_items[str(id)]
			inventory["amount"] -= item_amount 

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
				for slot in slots.get_children():
					if slot.item_id == index:
						slot.queue_free()
						break
		else:
			inventory_items[index]["amount"] = 1

#	func get_specifications(index, i) -> void:
#		var items = Items.new()
#		if items.content[index]["specifications"][i] is int:
#			specifications.text = specifications.text + "\n• " + get_tip(i) + ": "+ items.content[index]["specifications"][i]
#		else:
#			data.debug("[ID: "+str(index)+"] The '"+ str(i) +"' element is not a string.", "error")

func update_inventory_content() -> void:
	for items in inventory_items:
		check_amount(items)

#	func get_tip(tip:String) -> String:
#		match tip:
#			"growth":
#				return tr("Время роста")
#			"productivity":
#				return tr("Урожайность")
#			"conditions":
#				return tr("Условия")
#			_:
#				return ""

func check_item_type(i_type:Array) -> void:
	if main == "Farm"\
	|| main == "Greenhouse":
		for x in i_type:
			match x:
				"seeds":
					button_index = item_type.SEEDS
					button.visible = true
					if item.content[int(item_index)].has('crop'):
						var crop = item.content[int(item_index)]['crop']
						var crop_season = crops.crops[crop]['season']
						for i in crop_season:
							if main == "Farm":
								if i == clock.get_season():
									button.text = tr("inventory.button.plant_seeds")
									button.disabled = false
									break
								else:
									button.text = tr("inventory.button.wrong_season")
									button.disabled = !false
									break
							else:
								if main == "Greenhouse":
									button.text = tr("inventory.button.plant_seeds")
									button.disabled = false
									break
				"fertilizer":
					button_index = item_type.FERTILIZER
					button.visible = true
					button.text = tr("inventory.button.fertilize")
					button.disabled = false
				_:
					button_index = item_type.NOTHING
					button.visible = false

func _on_button_pressed():
	var items = Items.new().content
	var _audio = AudioStreamPlayer.new()
	self.add_child(_audio)
	_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
	_audio.stream = preload('res://assets/sounds/ui/click.ogg')
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
		_audio.stream = preload('res://assets/sounds/ui/click.ogg')
		_audio.play()

func _on_close_mouse_entered():
	if opened:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = preload('res://assets/sounds/ui/hover.ogg')
		_audio.play()
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_close_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	
func _on_button_mouse_entered():
	if visible:
		if !button.disabled:
			var _audio = AudioStreamPlayer.new()
			self.add_child(_audio)
			_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
			_audio.stream = preload('res://assets/sounds/ui/hover.ogg')
			_audio.play()
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_button_mouse_exited():
	if !button.disabled:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(_audio) -> void:
	_audio.queue_free()
