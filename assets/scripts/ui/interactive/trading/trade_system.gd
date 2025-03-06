extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")

@onready var playerInventoryCaption:Label = $Content/PlayerInventory/LabelMargin/Label
@onready var tradeInventoryCaption:Label = $Content/TraderInventory/LabelMargin/Label
@onready var header:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/HeaderContainer/Header
@onready var description_container:MarginContainer = $Content/TradeWindow/TradeWindow/VBoxContainer/DescriptionContainer
@onready var description:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/DescriptionContainer/Description
@onready var player_inventory_main:GridContainer = $Content/PlayerInventory/PlayerContainer/VBoxContainer/MarginContainer/GridContainer
@onready var trade_window_items:GridContainer =  $Content/TradeWindow/TradeWindow/VBoxContainer/ItemsContainer/GridMarginContainer/GridContainer
@onready var trade_window_items_container:MarginContainer = $Content/TradeWindow/TradeWindow/VBoxContainer/ItemsContainer
@onready var trade_window_header:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/HeaderContainer/Header
@onready var trade_window_target_price:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/TargetPriceContainer/TargetPrice
@onready var trade_window_button:Button = $Content/TradeWindow/TradeWindow/VBoxContainer/ButtonContainer/Button
@onready var trader_inventory_main:GridContainer = $Content/TraderInventory/TraderContainer/VBoxContainer/MarginContainer/GridContainer
@onready var trader_inventory_container:MarginContainer = $Content/TraderInventory/TraderContainer/VBoxContainer/MarginContainer
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var anim:AnimationPlayer = $Animation

var window_visible:bool = false
var opened:bool = false

enum transactions {NONE, PURCHASE, SELL}
enum initiators {NONE, PLAYER, TRADER}

var trader_id:int = 0
var target_price:int = 0
var transaction:int = transactions.NONE
var initiator:int = initiators.NONE

var trade_content:Dictionary = {}
var new_items_in_inventory = []
var simillar_items = []

var slots_inventory_to_create:Array = []
var slots_trader_to_create:Array = []
var current_inventory_slot_index:int
var current_trader_slot_index:int

var npc:Object = NPC.new()
var traders:Object = Traders.new()
var all_items:Object = Items.new()

func _ready():
	_update_window_visible()
	header.text = tr("Торговля")

func _process(_delta) -> void:
	if visible:
		if slots_inventory_to_create.size() > 0 && current_inventory_slot_index < slots_inventory_to_create.size():
			for i in range(1):
				if current_inventory_slot_index < slots_inventory_to_create.size():
					item_create(
							initiators.PLAYER, 
							inventory.inventory_items, 
							player_inventory_main, 
							slots_inventory_to_create[current_inventory_slot_index]
						)
					current_inventory_slot_index += 1
				else:
					break

		if slots_trader_to_create.size() > 0 && current_trader_slot_index < slots_trader_to_create.size():
			for i in range(1):
				if current_trader_slot_index < slots_trader_to_create.size():
					item_create(
							initiators.TRADER, 
							traders.content[trader_id]["inventory"]['seasons'][clock.get_season()], 
							trader_inventory_main, 
							slots_trader_to_create[current_trader_slot_index]
						)
					current_trader_slot_index += 1
				else:
					break

func create_all_items(type:String = "all") -> void:
	match type:
		"all":
			remove_player_inventory()
			remove_trader_inventory()
			slots_inventory_to_create = []
			slots_trader_to_create = []
			current_inventory_slot_index = 0
			current_trader_slot_index = 0
			var items = Items.new()
			for item in inventory.inventory_items:
				if items.content.has(int(item)):
					if inventory.inventory_items[item].has("amount"):
						if inventory.inventory_items[item]["amount"] > 0:
							slots_inventory_to_create.append(item)

			if traders.content[trader_id].has('inventory'):
				if traders.content[trader_id]['inventory'].has('seasons'):
					if traders.content[trader_id]['inventory']['seasons'].has(clock.get_season()):
						for item in traders.content[trader_id]['inventory']['seasons'][clock.get_season()]:
							if items.content.has(int(item)):
								if traders.content[trader_id]['inventory']['seasons'][clock.get_season()][item].has("amount"):
									if traders.content[trader_id]['inventory']['seasons'][clock.get_season()][item]["amount"] > 0:
										slots_trader_to_create.append(item)

			if slots_trader_to_create.size() > 0:
				trader_inventory_container.visible = true
		"player":
			remove_player_inventory()
			slots_inventory_to_create = []
			current_inventory_slot_index = 0
			var items = Items.new()
			for item in inventory.inventory_items:
				if items.content.has(int(item)):
					if inventory.inventory_items[item].has("amount"):
						if inventory.inventory_items[item]["amount"] > 0:
							slots_inventory_to_create.append(item)
		"trader":
			remove_player_inventory()
			slots_trader_to_create = []
			current_trader_slot_index = 0
			var items = Items.new()
			if traders.content[trader_id].has('inventory'):
				if traders.content[trader_id]['inventory'].has('seasons'):
					if traders.content[trader_id]['inventory']['seasons'].has(clock.get_season()):
						for item in traders.content[trader_id]['inventory']['seasons'][clock.get_season()]:
							if items.content.has(int(item)):
								if traders.content[trader_id]['inventory']['seasons'][clock.get_season()][item].has("amount"):
									if traders.content[trader_id]['inventory']['seasons'][clock.get_season()][item]["amount"] > 0:
										slots_trader_to_create.append(item)

			if slots_trader_to_create.size() > 0:
				trader_inventory_container.visible = true
		_:
			return

func item_create(slot_arg:int, items:Dictionary, container:GridContainer, id) -> void:
	var slot = inventory.node.instantiate()
	if items.has(id):
		if items[id]["amount"] > 0:
			container.add_child(slot)
			slot.set_data(id, items[id]["amount"])
			slot.tr_arg = slot_arg
		else:
			remove_item(items,id)
			data.debug("Invalid item index: " + str(id), "error")

func remove_item(inventory_container:Dictionary, id) -> void:
	if inventory_container.has(int(id)):
		inventory_container.erase(int(id))
	elif inventory_container.has(str(id)):
		inventory_container.erase(str(id))

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& opened:
		close_trade_menu()

func open_trade_menu(traderID:int) -> void:
	trader_id = traderID
	opened = true
	window_visible = true
	anim.play("open_menu")
	update_inventories_trade_menu()
	clear_all_trade_menu()
	if !blur.state:
		blur.blur(true)

func close_trade_menu() -> void:
	opened = false
	window_visible = false
	blur.blur(false)
	anim.play("close_menu")
	trader_id = 0

func remove_player_inventory() -> void:
	for i in player_inventory_main.get_children():
		player_inventory_main.remove_child(i)
		i.queue_free()

func get_items_trade_window() -> void:
	if trade_content != {}:
		trade_window_items_container.visible = true
		for item in trade_content:
			var node = inventory.node
			var slot = node.instantiate()
			trade_window_items.add_child(slot)
			slot.set_data(item, trade_content[item]["amount"])
			slot.tr_arg = slot.tr_initator.NONE

func set_item_trade_window(item_id, slot_arg, amount:int = 1) -> void:
	var node = inventory.node
	var slot = node.instantiate()
	match slot_arg:
		slot.tr_initator.PLAYER:
			initiator = initiators.PLAYER
			if !trade_content.has(item_id):
				trade_content[item_id] = {}
				if !trade_content[item_id].has("amount"):
					trade_content[item_id]["amount"] = amount
			else:
				if inventory.inventory_items.has(item_id):
					if trade_content[item_id]["amount"] + amount < inventory.inventory_items[item_id]["amount"]:
						trade_content[item_id]["amount"] += amount
					else:
						trade_content[item_id]["amount"] = inventory.inventory_items[item_id]["amount"]
			clear_trade_window()
			get_items_trade_window()
		slot.tr_initator.TRADER:
			initiator = initiators.TRADER
			if !trade_content.has(item_id):
				trade_content[item_id] = {}
				if !trade_content[item_id].has("amount"):
					trade_content[item_id]["amount"] = amount
			else:
				if trade_content[item_id]["amount"] >= 1:
					if trade_content[item_id]["amount"] + amount < traders.content[trader_id]["inventory"]['seasons'][clock.get_season()][item_id]["amount"]:
						trade_content[item_id]["amount"] += amount
					else:
						trade_content[item_id]["amount"] = traders.content[trader_id]["inventory"]['seasons'][clock.get_season()][item_id]["amount"]
			clear_trade_window()
			get_items_trade_window()
	update_button_trade_window()

func add_item_trade_window(item_id, slot_arg, amount:int = 1) -> void:
	var node = inventory.node
	var slot = node.instantiate()
	match slot_arg:
		slot.tr_initator.PLAYER:
			initiator = initiators.PLAYER
			if !trade_content.has(item_id):
				trade_content[item_id] = {}
				if !trade_content[item_id].has("amount"):
					trade_content[item_id]["amount"] = amount
			else:
				if inventory.inventory_items.has(item_id):
					if trade_content[item_id]["amount"] < inventory.inventory_items[item_id]["amount"]:
						trade_content[item_id]["amount"] += amount
			clear_trade_window()
			get_items_trade_window()
		slot.tr_initator.TRADER:
			initiator = initiators.TRADER
			if !trade_content.has(item_id):
				trade_content[item_id] = {}
				if !trade_content[item_id].has("amount"):
					trade_content[item_id]["amount"] = amount
			else:
				if trade_content[item_id]["amount"] >= 1:
					if trade_content[item_id]["amount"] < traders.content[trader_id]["inventory"]['seasons'][clock.get_season()][item_id]["amount"]:
						trade_content[item_id]["amount"] += amount
			clear_trade_window()
			get_items_trade_window()
	update_button_trade_window()

func remove_item_trade_window(item_id, amount:int = 1) -> void:
	for item in trade_content:
		if item_id == item:
			if trade_content[item_id].has("amount"):
				if trade_content[item_id]["amount"] == 1:
					trade_content.erase(item_id)
				else:
					if amount > 0:
						trade_content[item_id]["amount"] -= amount
					else:
						trade_content[item_id]["amount"] -= 1
			clear_trade_window()
			get_items_trade_window()
			update_button_trade_window()

func clear_trade_window() -> void:
	if trade_window_items.get_children() != []:
		for items in trade_window_items.get_children():
			trade_window_items.remove_child(items)
			items.queue_free()
		trade_window_items_container.visible = false

func get_target_price():
	if trade_content != {}:
		trade_window_target_price.visible = true
		var target_price_label:String
		target_price = 0
		if initiator == initiators.TRADER:
			target_price_label = tr("К оплате")
			for item in trade_content:
				if storage.object[storage.level]["slots"] - inventory.get_all_items() >= get_all_items_array():
					if all_items.content.has(int(item)):
						var sale_price = all_items.content[int(item)].get("purchase", null)
						if sale_price != null:
							var amount = trade_content[item].get("amount", 1)
							target_price += round(sale_price * amount)
						else:
							data.debug("the 'sale' parameter is missing","error")
					else:
						data.debug("Invalid item ID: " + str(item), "error")
		else:
			target_price_label = tr("Итог")
			for item in trade_content:
				if all_items.content.has(int(item)):
					var sale_price = all_items.content[int(item)].get("sale", null)
					if sale_price != null:
						var amount = trade_content[item].get("amount", 1)
						target_price += round(sale_price * amount)
					else:
						data.debug("the 'sale' parameter is missing","error")
				else:
					data.debug("Invalid item ID: " + str(item), "error")
		trade_window_target_price.text = target_price_label + ": " + str(balance.format(target_price))
	else:
		trade_window_target_price.visible = false
	
	return target_price

func get_all_items_array() -> int:
	var result:int = 0
	for i in new_items_in_inventory:
		result+=1
	return result

func update_button_trade_window() -> void:
	if trade_window_items.get_children() != []:
		match initiator:
			initiators.TRADER:
				trade_window_button.visible = true
				description_container.visible = false
				if storage.object[storage.level]["slots"] - inventory.get_all_items() >= get_all_items_array():
					if balance.money >= get_target_price():
						trade_window_button.text = tr("Купить")
						trade_window_button.disabled = false
					else:
						trade_window_button.text = tr("Недостаточно средств.")
						trade_window_button.disabled = true
				else:
					trade_window_button.text = tr("Склад полон")
					trade_window_button.disabled = true
			initiators.PLAYER:
				trade_window_button.text = tr("Продать")
				trade_window_button.visible = true
				trade_window_button.disabled = false
				description_container.visible = false
	else:
		trade_window_button.visible = false
		initiator = initiators.NONE
		description_container.visible = true
		description.text = tr("Для начала торговли выберите предмет из вашего инвентаря или инвентаря торговца.")
		playerInventoryCaption.text = tr("Ваш инвентарь:")
		if npc.content.has(trader_id):
			tradeInventoryCaption.text = npc.content[trader_id]['name']

func remove_trader_inventory() -> void:
	if trader_inventory_main.get_children() != []:
		for items in trader_inventory_main.get_children():
			trader_inventory_main.remove_child(items)
			items.queue_free()
		trader_inventory_container.visible = false

func updates_arrays():
	if trade_content:
		new_items_in_inventory = []
		simillar_items = []
		match initiator:
			initiators.TRADER:
				for id in trade_content.keys():
					var found = false
					for item in inventory.inventory_items:
						if int(item) == id:
							simillar_items.append(id)
							found = true
					if not found:
						new_items_in_inventory.append(id)

func get_trade_result():
	if trade_content != {}:
		match initiator:
			initiators.PLAYER:
				for id in trade_content:
					if inventory.inventory_items[id]["amount"] == 1:
						inventory.inventory_items.erase(id)
					else:
						inventory.inventory_items[id]["amount"] -= trade_content[id]["amount"]
			initiators.TRADER:
				for id in trade_content:
					if inventory.inventory_items.has(int(id)):
						inventory.inventory_items[int(id)]["amount"] += trade_content[id]["amount"]
					if inventory.inventory_items.has(str(id)):
						inventory.inventory_items[str(id)]["amount"] += trade_content[id]["amount"]

				for items_id in new_items_in_inventory:
					if !inventory.inventory_items.has(int(items_id)) && !inventory.inventory_items.has(str(items_id)):
						inventory.inventory_items[items_id] = {}
						inventory.inventory_items[items_id]["amount"] = trade_content[items_id]["amount"]

	if self.visible:
		match initiator:
			initiators.PLAYER:
				balance.add_money(target_price)
				clear_all_trade_menu()
				remove_player_inventory()
				create_all_items("player")
				trade_window_button.disabled = true
			initiators.TRADER:
				if balance.money >= target_price:
					balance.remove_money(target_price)
					clear_all_trade_menu()
					remove_player_inventory()
					remove_trader_inventory()
					create_all_items()
					trade_window_button.disabled = false
				else:
					trade_window_button.disabled = true
	initiator = initiators.NONE

func get_all_items_in_trade_window() -> int:
	var result:int = 0
	for items in trade_content:
		result+=1
	return result

func update_inventories_trade_menu() -> void:
	remove_player_inventory()
	remove_trader_inventory()
	create_all_items()

func clear_all_trade_menu() -> void:
	trade_content.clear()
	clear_trade_window()
	update_button_trade_window()
	get_target_price()

func _update_window_visible() -> void:
	visible = window_visible
	if pause:
		pause.other_menu = window_visible

func _on_button_pressed():
	match initiator:
		initiators.PLAYER:
			get_trade_result()
		initiators.TRADER:
			get_trade_result()
		_:
			pass

func _on_close_button_pressed():
	close_trade_menu()
