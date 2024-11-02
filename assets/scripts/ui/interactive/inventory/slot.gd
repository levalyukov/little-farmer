extends Control

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var signmenu:Control = get_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu")
@onready var trade_menu:Control = get_node("/root/"+main+"/UI/Interactive/TradeMenu")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var icon:TextureRect = $Button/Icon
@onready var amount_label:Label = $Button/Amount

@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")

var id
var amount:int
var item:Object = Items.new()
enum tr_initator {NONE, PLAYER, TRADER}
var tr_arg:int = 0

func set_data(index, item_amount) -> void:
	self.id = index
	if item.content.has(int(index)):
		self.amount = item_amount
		if item.content[int(index)].has("icon"):
			if item.content[int(index)]["icon"] is CompressedTexture2D:
				icon.texture = item.content[int(index)]["icon"]
				icon.visible = true
			else:
				icon.visible = false
				data.debug("[ID: "+str(index)+"] The key stores a non-Compressed 2D Texture.", "error")
		else:
			icon.visible = false
			data.debug("[ID: "+str(index)+"] The object does not have the 'icon' key.", "error")
		
		if typeof(amount) == TYPE_INT and amount > 0:
			if amount > 1:
				amount_label.visible = true
				if amount > item.maximum:
					amount = item.maximum
				amount_label.text = "x"+str(amount)
			else:
				amount_label.visible = false
		else:
			data.debug("[ID: "+str(index)+"] The object does not have the 'icon' key.", "error")
			amount_label.visible = false
	else:
		data.debug("Invalid index: " + str(index), "error")


func _on_button_mouse_entered():
	if has_node("/root/"+main+"/UI/Interactive/Mailbox"):
		if mailbox.menu:
			if item.content.has(int(id)):
				if item.content[int(id)].has("caption"):
					var item_amount:String = tr("x")
					tip.tooltip(
						item.content[int(id)]["caption"] + " [" + item_amount + str(amount) + "]"
						)
				else:
					print_debug("The 'caption' key is missing.", "error")
			else:
				data.debug("Invalid item ID: " + str(id))

	if has_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu"):
		if signmenu.menu:
			if item.content.has(int(id)):
				if item.content[int(id)].has("caption"):
					tip.tooltip(
						item.content[int(id)]["caption"]
						)
				else:
					data.debug("The 'caption' key is missing.", "error")
			else:
				data.debug("Invalid item ID: " + str(id), "warning")

	if has_node("/root/"+main+"/UI/Interactive/TradeMenu"):
		if trade_menu.visible:
			if blur.state:
				if id:
					if item.content.has(int(id)):
						if item.content[int(id)].has("caption"):
							tip.tooltip(
								item.content[int(id)]["caption"]
								)
						else:
							data.debug("The 'caption' key is missing.", "error")
					else:
						data.debug("Invalid item ID: " + str(id), "warning")

func _on_button_mouse_exited():
	if has_node("/root/"+main+"/UI/Interactive/Mailbox")\
	|| has_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu")\
	|| has_node("/root/"+main+"/UI/Interactive/TradeMenu"):
		if mailbox.menu\
		|| signmenu.menu\
		|| trade_menu.menu:
			tip.tooltip("")

func _on_button_pressed():
	if has_node("/root/"+main+"/UI/Interactive/Inventory"):
		if inventory.visible:
				inventory.get_data(id)

	if has_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu"):
		if signmenu.visible:
			if blur.state:
				for i in buildings.get_children():
					if i.name == signmenu.sign_name:
						i.set_sign_sprite(int(id))
						signmenu._close()

	if has_node("/root/"+main+"/UI/Interactive/TradeMenu"):
		match tr_arg:
			tr_initator.PLAYER:
				if trade_menu:
					if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.NONE:
						trade_menu.add_item_trade_window(id, tr_initator.PLAYER)
						trade_menu.updates_arrays()
						trade_menu.get_target_price()
						trade_menu.update_button_trade_window()
			tr_initator.TRADER:
				if trade_menu:
					if trade_menu.initiator == trade_menu.initiators.TRADER || trade_menu.initiator == trade_menu.initiators.NONE:
						trade_menu.add_item_trade_window(id, tr_initator.TRADER)
						trade_menu.updates_arrays()
						trade_menu.get_target_price()
						trade_menu.update_button_trade_window()
			tr_initator.NONE:
				if trade_menu:
					if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.TRADER:
						trade_menu.remove_item_trade_window(id)
						if trade_menu.initiator == trade_menu.initiators.TRADER:
							trade_menu.updates_arrays()
						trade_menu.update_button_trade_window()
						trade_menu.get_target_price()
			_:
				pass
		print("Initiator: ", trade_menu.initiator)
		print("Aviabled slots: ", str(storage.object[storage.level]["slots"] - inventory.get_all_items()))
		print("Trade slots: ", trade_menu.get_all_items_in_trade_window())
		print("New items in inventory: ", trade_menu.new_items_in_inventory)
		print("Simillar items: ", trade_menu.simillar_items)
