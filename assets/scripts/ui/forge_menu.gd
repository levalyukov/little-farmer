extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

@onready var header:Label = $Panel/VBox/HeaderMargin/Label
@onready var oreIcon:TextureRect = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/OreContainer/TextureRect
@onready var fuelIcon:TextureRect = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/CoalContainer/TextureRect
@onready var ignotIcon:TextureRect = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/IgnorContainer/TextureRect
@onready var labelStatus:Label = $Panel/VBox/MainInfo/VBoxContainer/MarginContainer/LabelStatus
@onready var meltButton:Button = $Panel/VBox/MainInfo/VBoxContainer/MeltButton
@onready var playerInventoryMargin:MarginContainer = $Panel/VBox/PlayerInventory
@onready var playerInventory:GridContainer = $Panel/VBox/PlayerInventory/MarginContainer/ScrollContainer/GridContainer
@onready var anim:AnimationPlayer = $AnimationPlayer

@onready var oreAmountLabel:Label = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/OreContainer/LabelAmount
@onready var fuelAmountLabel:Label = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/CoalContainer/LabelAmount
@onready var ignotAmountLabel:Label = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/IgnorContainer/LabelAmount

const ORE_SLOT_DEFAULT:Resource = preload('res://assets/resources/ui/interactive/inventory/items/resources/copper_ore.png')
const FUEL_SLOT_DEFAULT:Resource = preload('res://assets/resources/ui/interactive/inventory/items/resources/coal.png')
const ORE_THRESHOLD:int = 5
const FUEL_THRESHOLD:int = 5

var audio = AudioStreamPlayer.new()
var items:Object = Items.new()

var current_slot_index:int = 0
var slots_to_create:Array = []
var opened:bool = false

var ore_id
var fuel_id
var ore_amount:int = 0
var fuel_amount:int = 0
var target_node:Node2D

func _ready():
	close()
	self.add_child(audio)
	header.text = tr('object.forge.caption')

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		close()

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

func update_forge_state() -> void:
	if target_node:
		if target_node.isDone:
			if !ignotIcon.visible:
				ignotIcon.visible = true
				ignotIcon.texture = items.content[int(target_node.ignot_id)]['icon']
				ore_id = 0
				fuel_id = 0
				ore_amount = 0
				fuel_amount = 0
			if target_node.ignot_amount > 1:
				ignotAmountLabel.text = "x"+str(target_node.ignot_amount)
		
		if target_node.inProcessed:
			meltButton.visible = false
			playerInventoryMargin.visible = false
			if target_node.value_process <= 100.0:
				var formatted_value = "%.2f" % target_node.value_process
				labelStatus.text = tr("forge.status.melting") + "\n(%s%%)" % formatted_value
			else:
				if !meltButton.visible:
					meltButton.visible = true
					labelStatus.text = tr("forge.status.ignot_ready")
		else:
			meltButton.visible = !false

func update_ore_value() -> void:
	if ore_amount > 0:
		oreAmountLabel.text = "x"+str(ore_amount)
	else:
		oreIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
		oreAmountLabel.text = ''

func update_fuel_value() -> void:
	if fuel_amount > 0:
		fuelAmountLabel.text = "x"+str(fuel_amount)
	else:
		fuelIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
		fuelAmountLabel.text = ''

func get_result() -> int:
	if target_node:
		if items.content.has(target_node.ignot_id):
			return target_node.ignot_id
	return 0

func add_item(id) -> void:
	if items.content.has(int(id)):
		if items.content[int(id)].has('item_type'):
			if items.content[int(id)]['item_type'].has('ore'):
				if inventory.inventory_items.has(id):
					if inventory.inventory_items[id].has('amount'):
						if inventory.inventory_items[id]['amount'] >= ORE_THRESHOLD:
							if ore_amount + 5 <= inventory.inventory_items[id]['amount']:
								oreIcon.texture = items.content[int(id)]['icon']
								oreIcon.modulate = Color(1, 1, 1)
								if ore_id is int:
									if ore_id == int(id):
										ore_amount += 5
									else:
										ore_amount = 5
								elif ore_id is String:
									if ore_id == str(id):
										ore_amount += 5
									else:
										ore_amount = 5
								ore_id = id
				update_ore_value()
			if items.content[int(id)]['item_type'].has('fuel'):
				if inventory.inventory_items.has(id):
					if inventory.inventory_items[id].has('amount'):
						if inventory.inventory_items[id]['amount'] >= ORE_THRESHOLD:
							if fuel_amount + 5 <= inventory.inventory_items[id]['amount']:					
								fuelIcon.modulate = Color(1, 1, 1)
								fuelIcon.texture = items.content[int(id)]['icon']
								if fuel_id is int:
									if fuel_id == int(id):
										fuel_amount += 5
									else:
										fuel_amount = 5
								if fuel_id is String:
									if fuel_id == str(id):
										fuel_amount += 5
									else:
										fuel_amount = 5
								fuel_id = id
				update_fuel_value()
				

func remove_item(id) -> void:
	if items.content.has(int(id)):
		if items.content[int(id)].has('item_type'):
			match items.content[int(id)]['item_type']:
				'ore':
					if ore_amount > 0:
						ore_amount -= 5
					else:
						oreIcon.texture = ORE_SLOT_DEFAULT
						oreIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
						ore_id = 0
						ore_amount = 0
				'fuel':
					if fuel_amount > 0:
						fuel_amount -= 5
					else:
						fuelIcon.texture = FUEL_SLOT_DEFAULT
						fuelIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
						fuel_id = 0
						fuel_amount = 0

func item_create(item_id) -> void:
	var slot = inventory.node.instantiate()
	if inventory.inventory_items.has(item_id):
		if inventory.inventory_items[item_id]["amount"] > 0:
			var item_amount = inventory.inventory_items[item_id]["amount"]
			var item_icon = items.content[int(item_id)]["icon"]
			var item_caption = items.content[int(item_id)]["caption"]
			playerInventory.add_child(slot)
			slot.set_data(
				item_id,
				item_amount,
				item_icon,
				item_caption
			)

func get_special_items() -> void:
	for z in playerInventory.get_children():
		playerInventory.remove_child(z)

	for i in inventory.inventory_items:
		if items.content.has(int(i)):
			if items.content[int(i)].has('item_type'):
				if items.content[int(i)]['item_type'] is Array:
					if items.content[int(i)]['item_type'].has("ore")\
					|| items.content[int(i)]['item_type'].has("fuel"):
						slots_to_create.append(i)

	set_process(true)

func check_button_state() -> void:
	if target_node:
		if !target_node.inProcessed:
			meltButton.text = tr('forge.button.melt')
			if (int(ore_id) > 0 && ore_amount >= ORE_THRESHOLD)\
			&& (int(fuel_id) > 0 && fuel_amount >= FUEL_THRESHOLD)\
			&& ore_amount == fuel_amount:
				meltButton.disabled = false
			else:
				meltButton.disabled = !false
		if target_node.isDone:
			meltButton.text = tr('forge.button.get_ignot')
			meltButton.disabled = false

func open(node:Node2D) -> void:
	opened = true
	blur.blur(true)
	target_node = node
	get_special_items()
	check_button_state()
	anim.play('open')
	check_window()
	update_forge_state()
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if audio:
		if !audio.is_playing():
			audio.stream = load('res://assets/sounds/buildings/forge.ogg')
			audio.play()

	if get_result() != 0:
		ignotIcon.visible = true
		ignotIcon.texture = items.content[get_result()]['icon']
	else:
		ignotIcon.visible = !true

	if !target_node.inProcessed\
	&& !target_node.isDone:
		labelStatus.text = tr('forge.description_text') + '\n' + tr('forge.formula_text')
		oreIcon.texture = ORE_SLOT_DEFAULT
		fuelIcon.texture = FUEL_SLOT_DEFAULT
		oreAmountLabel.text = ""
		fuelAmountLabel.text = ""
		oreIcon.modulate  = Color(0.8, 0.8, 0.8, 0.49)
		fuelIcon.modulate  = Color(0.8, 0.8, 0.8, 0.49)
		ignotAmountLabel.text = ''
		if !playerInventoryMargin.visible:
			playerInventoryMargin.visible = true
	elif !target_node.inProcessed\
	&& target_node.isDone:
		labelStatus.text = tr("forge.status.ignot_ready")
		if playerInventoryMargin.visible:
			playerInventoryMargin.visible = false
	else:
		ore_id = target_node.ore_id
		fuel_id = target_node.fuel_id
		ore_amount = target_node.ore_amount
		fuel_amount = target_node.fuel_amount

		if target_node.ore_id > 0:
			if target_node.ore_amount > 0:
				if items.content.has(ore_id):
					oreIcon.texture = items.content[ore_id]['icon']
					oreAmountLabel.text = "x" + str(ore_amount)
					oreIcon.modulate = Color(1, 1, 1)
		if target_node.fuel_id > 0:
			if target_node.fuel_amount > 0:
				if items.content.has(fuel_id):
					fuelIcon.texture = items.content[fuel_id]['icon']
					fuelAmountLabel.text = "x" + str(fuel_amount)
					fuelIcon.modulate = Color(1, 1, 1)
	
		if playerInventoryMargin.visible:
			playerInventoryMargin.visible = false

func close() -> void:
	opened = !true
	blur.blur(!true)
	anim.play('close')
	ore_id = 0
	ore_amount = 0
	fuel_id = 0
	fuel_amount = 0
	target_node = null
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	check_window()

func check_window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

# Removing ore
func _on_remove_ore_pressed():
	if !target_node.inProcessed:
		if ore_id != null:
			remove_item(ore_id)
			check_button_state()
			update_ore_value()

# Removing fuel
func _on_remove_fuel_pressed():
	if !target_node.inProcessed:
		if fuel_id != null:
			remove_item(fuel_id)
			check_button_state()
			update_fuel_value()
#
func _on_melt_button_pressed():
	if !target_node.inProcessed:
		if !target_node.isDone:
			if ore_amount == fuel_amount:
				target_node.start_melt(
					int(ore_id), 
					ore_amount, 
					int(fuel_id), 
					fuel_amount
				)
				inventory.subject_item(ore_id,ore_amount)
				inventory.subject_item(fuel_id,fuel_amount)
				update_forge_state()
		else:
			if target_node.isDone:
				if items.content.has(int(target_node.ignot_id)):
					inventory.add_item(target_node.ignot_id, target_node.ignot_amount)
					target_node.ignot_id = 0
					target_node.ignot_amount = 0
					target_node.value_process = 0.0
					ore_id = 0
					fuel_id = 0
					ore_amount = 0
					fuel_amount = 0
					target_node.ore_id = 0
					target_node.fuel_id = 0
					target_node.ore_amount = 0
					target_node.fuel_amount = 0
					ignotIcon.visible = false
					target_node.isDone = false
					ignotAmountLabel.text = ''
					labelStatus.text = tr('forge.description_text') + '\n' + tr('forge.formula_text')
					meltButton.text = tr('forge.button.melt')
					meltButton.disabled = true
					playerInventoryMargin.visible = true
					get_special_items()
					check_button_state()
					update_ore_value()
					update_fuel_value()
					update_forge_state()
	_play_sound('ui/click')

# Close
func _on_close_button_pressed():
	_play_sound('ui/click')
	close()

func _on_close_button_mouse_entered():
	if cursor: cursor.set_cursor(cursor.states.ACTIVE)
	_play_sound('ui/hover')

func _on_close_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_melt_button_mouse_entered():
	if !meltButton.disabled:
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)
		_play_sound('ui/hover')

func _on_melt_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_get_ignot_mouse_entered():
	if target_node:
		if target_node.ignot_amount > 0:
			if cursor: cursor.set_cursor(cursor.states.ACTIVE)
			_play_sound('ui/hover')

func _on_get_ignot_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _play_sound(path_ogg:String) -> void:
	var ogg = AudioStreamPlayer.new()
	self.add_child(ogg)
	ogg.connect("finished", Callable(self, "_on_audio_finished").bind(ogg))
	ogg.stream = load('res://assets/sounds/'+path_ogg+'.ogg')
	ogg.play()

func _on_audio_finished(node) -> void:
	node.queue_free()
