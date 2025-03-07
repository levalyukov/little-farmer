extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")

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

var items:Object = Items.new()
var current_slot_index:int = 0
var slots_to_create:Array = []
var opened:bool = false

var ore_id:int
var ore_amount:int = 0

var fuel_id:int
var fuel_amount:int = 0

var ignot_id:int
var ignot_amount:int = 0

var ore_having:bool = false
var fuel_having:bool = false
var ignot_having:bool = false
var target_node:Node2D

func _ready():
	close()

func _process(_delta) -> void:
	if visible:
		# Creating slots
		if slots_to_create.size() > 0 and current_slot_index < slots_to_create.size():
			for i in range(1):
				if current_slot_index < slots_to_create.size():
					item_create(slots_to_create[current_slot_index])
					current_slot_index += 1
				else:
					break

		if target_node:
			if target_node.isDone:
				if !ignotIcon.visible:
					ignotIcon.visible = true
					ignotIcon.texture = items.content[target_node.ignot_id]['icon']
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
					labelStatus.text = tr("Плавка") + "\n(%s%%)" % formatted_value
				else:
					labelStatus.text = tr("Слиток готов.")
			else:
				meltButton.visible = !false

		if ore_amount > 0:
			oreAmountLabel.text = "x"+str(ore_amount)
		else:
			oreIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
			oreAmountLabel.text = ''
		if fuel_amount > 0:
			fuelAmountLabel.text = "x"+str(fuel_amount)
		else:
			fuelIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
			fuelAmountLabel.text = ''
		if ignot_amount > 0:
			ignotAmountLabel.text = "x"+str(ignot_amount)
		else:
			ignotAmountLabel.text = ''

func set_result(id) -> void:
	pass

func get_result() -> int:
	if target_node:
		if items.content.has(target_node.ignot_id):
			return target_node.ignot_id
	return 0

func add_item(id) -> void:
	if items.content.has(id):
		if items.content[id].has('item_type'):
			match items.content[id]['item_type']:
				'ore':
					if inventory.inventory_items.has(id):
						if inventory.inventory_items[id].has('amount'):
							if inventory.inventory_items[id]['amount'] >= ORE_THRESHOLD:
								oreIcon.texture = items.content[id]['icon']
								oreIcon.modulate = Color(1, 1, 1)
								ore_having = true
								if ore_id == id:
									ore_amount += 5
								else:
									ore_amount = 5
								ore_id = int(id)
				'fuel':
					if inventory.inventory_items.has(id):
						if inventory.inventory_items[id].has('amount'):
							if inventory.inventory_items[id]['amount'] >= ORE_THRESHOLD:							
								fuel_having = true
								fuelIcon.modulate = Color(1, 1, 1)
								fuelIcon.texture = items.content[id]['icon']
								if fuel_id == id:
									fuel_amount += 5
								else:
									fuel_amount = 5
								fuel_id = int(id)

func remove_item(id) -> void:
	if items.content[id].has('item_type'):
		match items.content[id]['item_type']:
			'ore':
				if ore_amount > 0:
					ore_amount -= 5
				else:
					oreIcon.texture = ORE_SLOT_DEFAULT
					oreIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
					ore_having = !true
					ore_id = 0
					ore_amount = 0
			'fuel':
				if fuel_amount > 0:
					fuel_amount -= 5
				else:
					fuelIcon.texture = FUEL_SLOT_DEFAULT
					fuelIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
					fuel_having = !true
					fuel_id = 0
					fuel_amount = 0

func item_create(id) -> void:
	var slot = inventory.node.instantiate()
	if inventory.inventory_items.has(id):
		if inventory.inventory_items[id]["amount"] > 0:
			playerInventory.add_child(slot)
			slot.set_data(id, inventory.inventory_items[id]["amount"])

func get_special_items() -> void:
	for z in playerInventory.get_children():
		playerInventory.remove_child(z)

	for i in inventory.inventory_items:
		if items.content.has(i):
			if items.content[i].has('item_type'):
				if items.content[i]['item_type'] is String:
					if items.content[i]['item_type'] == "ore":
						slots_to_create.append(i)
					if items.content[i]['item_type'] == "fuel":
						slots_to_create.append(i)

func check_button_state() -> void:
	if !target_node.inProcessed:
		meltButton.text = tr('Переплавить')
		if (ore_id > 0 && ore_amount >= ORE_THRESHOLD)\
		&& (fuel_id > 0 && fuel_amount >= FUEL_THRESHOLD)\
		&& ore_amount == fuel_amount:
			meltButton.disabled = false
		else:
			meltButton.disabled = !false
	if target_node.isDone:
		meltButton.text = tr('Получить слиток')
		meltButton.disabled = false

func open(node:Node2D) -> void:
	opened = true
	blur.blur(true)
	target_node = node
	get_special_items()
	check_button_state()
	anim.play('open')
	if get_result() != 0:
		ignotIcon.visible = true
		ignotIcon.texture = items.content[get_result()]['icon']
	else:
		ignotIcon.visible = !true
	if !target_node.inProcessed:
		labelStatus.text = tr('Выберите из инвентаря уголь и руду для переплавки.')
		oreIcon.texture = ORE_SLOT_DEFAULT
		fuelIcon.texture = FUEL_SLOT_DEFAULT
		oreAmountLabel.text = ""
		fuelAmountLabel.text = ""
		oreIcon.modulate  = Color(0.8, 0.8, 0.8, 0.49)
		fuelIcon.modulate  = Color(0.8, 0.8, 0.8, 0.49)
		if !playerInventoryMargin.visible:
			playerInventoryMargin.visible = true
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
	ignot_id = 0
	ignot_amount = 0
	target_node = null

func window() -> void:
	visible = opened

# Removing ore
func _on_remove_ore_pressed():
	if !target_node.inProcessed:
		if ore_id > 0:
			remove_item(ore_id)
			check_button_state()

# Removing fuel
func _on_remove_fuel_pressed():
	if !target_node.inProcessed:
		if fuel_id > 0:
			remove_item(fuel_id)
			check_button_state()

# Get Ignot
func _on_get_ignot_pressed():
	pass
	#	if !target_node.inProcessed:
	#		if target_node.isDone:
	#			if items.content.has(target_node.ignot_id):
	#				print('get ignot')
#
func _on_melt_button_pressed():
	if !target_node.inProcessed:
		if !target_node.isDone:
			if ore_amount == fuel_amount:
				target_node.start_melt(
					ore_id, 
					ore_amount, 
					fuel_id, 
					fuel_amount
				)
				inventory.subject_item(ore_id,ore_amount)
				inventory.subject_item(fuel_id,fuel_amount)
		else:
			if items.content.has(target_node.ignot_id):
				print('get ignot')

# Close
func _on_close_button_pressed():
	if visible:
		close()
