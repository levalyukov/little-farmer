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
@onready var coalIcon:TextureRect = $Panel/VBox/MarginContainer/MarginContainer/HBoxContainer/CoalContainer/TextureRect
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
			if target_node.inProcessed:
				meltButton.visible = false
				playerInventoryMargin.visible = false
				var formatted_value = "%.2f" % target_node.value_process
				labelStatus.text = tr("Плавка") + "\n(%s%%)" % formatted_value	
			else:
				meltButton.visible = !false

		if ore_amount > 0:
			oreAmountLabel.text = "x"+str(ore_amount)
		if fuel_amount > 0:
			fuelAmountLabel.text = "x"+str(fuel_amount)
		if ignot_amount > 0:
			ignotAmountLabel.text = "x"+str(ignot_amount)

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
								coalIcon.modulate = Color(1, 1, 1)
								coalIcon.texture = items.content[id]['icon']
								if fuel_id == id:
									fuel_amount += 5
								else:
									fuel_amount = 5
								fuel_id = int(id)

func remove_item(id) -> void:
	if items.content[id].has('item_type'):
		match items.content[id]['item_type']:
			'ore':
				if ore_amount > 1:
					ore_amount -= 5
				else:
					oreIcon.texture = ORE_SLOT_DEFAULT
					oreIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
					ore_having = !true
					ore_id = 0
					ore_amount = 0
			'fuel':
				if fuel_amount > 1:
					fuel_amount -= 5
				else:
					coalIcon.texture = FUEL_SLOT_DEFAULT
					coalIcon.modulate = Color(0.8, 0.8, 0.8, 0.49)
					fuel_having = !true
					fuel_id = 0
					fuel_amount = 0

func item_create(id) -> void:
	var slot = inventory.node.instantiate()
	if inventory.inventory_items.has(id):
		if inventory.inventory_items[id]["amount"] > 0:
			playerInventory.add_child(slot)
			slot.set_data(id, inventory.inventory_items[id]["amount"])
			slot.cmpst_type = 0

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
		&& (fuel_id > 0 && fuel_amount >= FUEL_THRESHOLD):
			meltButton.disabled = false
		else:
			meltButton.disabled = !false
	else:
		meltButton.text = tr('Получить слиток')
		meltButton.disabled = false

func open(node:Node2D) -> void:
	opened = true
	blur.blur(true)
	target_node = node
	get_special_items()
	anim.play('open')

func close() -> void:
	opened = !true
	blur.blur(!true)
	target_node = null
	anim.play('close')

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
	if !target_node.inProcessed:
		if target_node.ignot_done:
			if ignot_id > 0\
			&& ignot_amount > 0:
				print('get ignot')

#
func _on_melt_button_pressed():
	if !target_node.inProcessed:
		target_node.start_melt(ore_amount, fuel_amount)

# Close
func _on_close_button_pressed():
	if visible:
		close()