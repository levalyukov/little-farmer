extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")

@onready var player_inventory_main:GridContainer = $Content/PlayerInventory/PlayerContainer/VBoxContainer/MarginContainer/GridContainer
@onready var trade_window_items:GridContainer =  $Content/TradeWindow/TradeWindow/VBoxContainer/ItemsContainer/GridMarginContainer/GridContainer
@onready var trade_window_items_container:MarginContainer = $Content/TradeWindow/TradeWindow/VBoxContainer/ItemsContainer
@onready var trade_window_header:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/HeaderContainer/Header
@onready var trade_window_target_price:Label = $Content/TradeWindow/TradeWindow/VBoxContainer/TargetPriceContainer/TargetPrice
@onready var trade_window_button:Button = $Content/TradeWindow/TradeWindow/VBoxContainer/ButtonContainer/Button
@onready var trader_inventory_main:GridContainer = $Content/TraderInventory/TraderContainer/VBoxContainer/MarginContainer/GridContainer
@onready var trader_inventory_container:MarginContainer = $Content/TraderInventory/TraderContainer/VBoxContainer/MarginContainer
@onready var anim:AnimationPlayer = $Animation

var window_visible:bool = false
var menu:bool = false

enum transactions {NONE, PURCHASE, SELL}
enum initiators {NONE, PLAYER, TRADER}

var trader_id:int = 1
var target_price:float = 0.0
var transaction:int = transactions.NONE
var initiator:int = initiators.NONE

var player_inventory:Dictionary = {}
var trade_content:Dictionary = {}
var trader_inventory:Dictionary = {}
var new_items_in_inventory = []
var simillar_items = []

var traders:Object = Traders.new()
var all_items:Object = Items.new()

func _ready():
	_update_window_visible()

func _process(_delta):
	if Input.is_action_just_pressed("test")\
	&& !visible:
		open_trade_menu()

	if Input.is_action_just_pressed("test")\
	&& visible:
		close_trade_menu()

func open_trade_menu() -> void:
	menu = true
	pause.other_menu = true
	window_visible = true
	blur.blur(true)
	anim.play("open_menu")
	update_inventories_trade_menu()
	clear_all_trade_menu()

func close_trade_menu() -> void:
	menu = false
	pause.other_menu = false
	window_visible = false
	blur.blur(false)
	anim.play("close_menu")

func remove_player_inventory() -> void:
	for i in player_inventory_main.get_children():
		player_inventory_main.remove_child(i)
		i.queue_free()

func get_player_inventory() -> void:
	var ids_to_remove = []
	if inventory:
		player_inventory = inventory.inventory_items
		if player_inventory != {}:
			for id in player_inventory:
				if player_inventory[id]["amount"] > 0:
					var node = inventory.node
					var slot = node.instantiate()
					player_inventory_main.add_child(slot)
					slot.set_data(id, player_inventory[id]["amount"])
					slot.tr_arg = slot.tr_initator.PLAYER
				else:
					ids_to_remove.append(id)

		for id in ids_to_remove:
			player_inventory.erase(id)

func get_items_trade_window() -> void:
	if trade_content != {}:
		trade_window_items_container.visible = true
		for item in trade_content:
			var node = inventory.node
			var slot = node.instantiate()
			trade_window_items.add_child(slot)
			slot.set_data(item, trade_content[item]["amount"])
			slot.tr_arg = slot.tr_initator.NONE

func add_item_trade_window(item_id, slot_arg) -> void:
	var node = inventory.node
	var slot = node.instantiate()
	match slot_arg:
		slot.tr_initator.PLAYER:
			initiator = initiators.PLAYER
			if !trade_content.has(item_id):
				trade_content[item_id] = {}
				if !trade_content[item_id].has("amount"):
					trade_content[item_id]["amount"] = 1
			else:
				if player_inventory.has(item_id):
					if trade_content[item_id]["amount"] < player_inventory[item_id]["amount"]:
						trade_content[item_id]["amount"] += 1
			clear_trade_window()
			get_items_trade_window()
		slot.tr_initator.TRADER:
			initiator = initiators.TRADER
			if !trade_content.has(item_id):
				trade_content[item_id] = {}
				if !trade_content[item_id].has("amount"):
					trade_content[item_id]["amount"] = 1
			else:
				if trade_content[item_id]["amount"] >= 1:
					if trade_content[item_id]["amount"] < trader_inventory[item_id]["max"]:
						trade_content[item_id]["amount"] += 1
			clear_trade_window()
			get_items_trade_window()
		_:
			pass
	update_button_trade_window()

func remove_item_trade_window(item_id) -> void:
	for item in trade_content:
		if item_id == item:
			if trade_content[item_id].has("amount"):
				if trade_content[item_id]["amount"] == 1:
					trade_content.erase(item_id)
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
		var target_price_label = tr("target_price_label")
		target_price = 0.0
		if initiator == initiators.TRADER:
			for item in trade_content:
				if storage.object[storage.level]["slots"] - inventory.get_all_items() >= get_all_items_array():
					if all_items.content.has(int(item)):
						var sale_price = all_items.content[int(item)].get("sale", null)
						if sale_price != null:
							var amount = trade_content[item].get("amount", 1)
							target_price += sale_price * amount
						else:
							data.debug("the 'sale' parameter is missing","error")
					else:
						data.debug("Invalid item ID: " + str(item), "error")
		else:
			for item in trade_content:
				if all_items.content.has(int(item)):
					var sale_price = all_items.content[int(item)].get("sale", null)
					if sale_price != null:
						var amount = trade_content[item].get("amount", 1)
						target_price += sale_price * amount
					else:
						data.debug("the 'sale' parameter is missing","error")
				else:
					data.debug("Invalid item ID: " + str(item), "error")
		trade_window_target_price.text = target_price_label + ": " + str(target_price)
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
				if storage.object[storage.level]["slots"] - inventory.get_all_items() >= get_all_items_array():
					if balance.money >= get_target_price():
						trade_window_button.text = tr("trader.button_purchase")
						trade_window_button.disabled = false
					else:
						trade_window_button.text = tr("trader.insufficient_funds")
						trade_window_button.disabled = true
				else:
					trade_window_button.text = tr("trader.error_full_inventory")
					trade_window_button.disabled = true
			initiators.PLAYER:
				trade_window_button.text = tr("trader.button_sell")
				trade_window_button.visible = true
				trade_window_button.disabled = false
	else:
		trade_window_button.visible = false
		initiator = initiators.NONE

func get_trader_inventory() -> void:
	if traders.content.has(trader_id):
		if traders.content[trader_id].has("inventory"):
			if traders.content[trader_id]["inventory"] is Dictionary:
				trader_inventory = traders.content[trader_id]["inventory"]
				trader_inventory_container.visible = true
				for products in traders.content[trader_id]["inventory"]:
					var node = inventory.node
					var slot = node.instantiate()
					trader_inventory_main.add_child(slot)
					slot.set_data(products, traders.content[trader_id]["inventory"][products]["amount"])
					slot.tr_arg = slot.tr_initator.TRADER
		else:
			data.debug("")
	else:
		data.debug("Invalid trader ID", "error")

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
					for item in player_inventory:
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
					if player_inventory[id]["amount"] == 1:
						player_inventory.erase(id)
					else:
						player_inventory[id]["amount"] -= trade_content[id]["amount"]
			initiators.TRADER:
				for id in trade_content:
					if player_inventory.has(id):
						player_inventory[id]["amount"] += trade_content[id]["amount"]

				if storage.object[storage.level]["slots"] - inventory.get_all_items() >= get_all_items_array():
					for items_id in new_items_in_inventory:
						if !player_inventory.has(items_id):
							player_inventory[items_id] = {}
							player_inventory[items_id]["amount"] = trade_content[items_id]["amount"]

	if self.visible:
		match initiator:
			initiators.PLAYER:
				balance.add_money(target_price)
				clear_all_trade_menu()
				remove_player_inventory()
				get_player_inventory()
				trade_window_button.disabled = true
			initiators.TRADER:
				if balance.money >= target_price:
					balance.remove_money(target_price)
					clear_all_trade_menu()
					remove_player_inventory()
					get_player_inventory()
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
	get_player_inventory()
	remove_trader_inventory()
	get_trader_inventory()

func clear_all_trade_menu() -> void:
	trade_content.clear()
	clear_trade_window()
	update_button_trade_window()
	get_target_price()

func _update_window_visible() -> void:
	visible = window_visible

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
