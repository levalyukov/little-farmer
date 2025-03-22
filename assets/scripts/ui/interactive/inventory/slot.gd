extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var mailbox:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")
@onready var signmenu:Control = get_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu")
@onready var trade_menu:Control = get_node("/root/"+main+"/UI/Interactive/TradeMenu")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var composterMenu:Control = get_node("/root/"+main+"/UI/Interactive/ComposterMenu")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var stoneMenu:Control = get_node("/root/"+main+"/UI/Interactive/StoneOvenMenu")
@onready var sawmillMenu:Control = get_node("/root/"+main+"/UI/Interactive/SawmillMenu")
@onready var icon:TextureRect = $Button/Icon
@onready var amount_label:Label = $Button/Amount

var id
var amount:int
var item:Object = Items.new()
enum tr_initator {NONE, PLAYER, TRADER}
var tr_arg:int = 0

var cmpst_type:int = 0

func _process(_delta):
	if visible:
		if id != null:
			if item.content.has(int(id)):
				if amount > 1:
					if amount_label:
						amount_label.visible = true
						amount_label.text = "x"+str(amount)
					if amount >= item.maximum:
						amount_label.text = "x"+str(item.maximum)
				else:
					amount_label.visible = false
			if amount <= 0:
				self.queue_free()

func set_data(index, item_amount:int = 1) -> void:
	id = index
	amount = item_amount
	if item.content.has(int(index)):
		if item.content[int(index)].has("icon"):
			if item.content[int(index)]["icon"] is CompressedTexture2D:
				if icon:
					icon.texture = item.content[int(index)]["icon"]
					icon.visible = true
			else:
				icon.visible = false
				data.debug("[ID: "+str(index)+"] The key stores a non-Compressed 2D Texture.", "error")
		else:
			icon.visible = false
			data.debug("[ID: "+str(index)+"] The object does not have the 'icon' key.", "error")

	else:
		data.debug("Invalid index: " + str(index), "error")


func _on_button_mouse_entered():
	if has_node("/root/"+main+"/UI/Interactive/Mailbox"):
		if mailbox:
			if mailbox.opened:
				if item.content.has(int(id)):
					if item.content[int(id)].has("caption"):
						var item_amount:String = "x"
						tip.tooltip(
							item.content[int(id)]["caption"] + " [" + item_amount + str(amount) + "]"
							)
					else:
						print_debug("The 'caption' key is missing.", "error")
				else:
					data.debug("Invalid item ID: " + str(id))

	if has_node("/root/"+main+"/UI/Interactive/BuildingsMenu/SignMenu"):
		if signmenu.opened:
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

	if has_node("/root/"+main+"/UI/Interactive/ComposterMenu"):
		if composterMenu.visible:
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
	
	if has_node("/root/"+main+"/UI/Interactive/StoneOvenMenu"):
		if stoneMenu.visible:
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
	|| has_node("/root/"+main+"/UI/Interactive/TradeMenu")\
	|| has_node("/root/"+main+"/UI/Interactive/ComposterMenu")\
	|| has_node("/root/"+main+"/UI/Interactive/StoneOvenMenu"):
		if mailbox.opened\
		|| signmenu.opened\
		|| trade_menu.opened\
		|| composterMenu.opened\
		|| stoneMenu.opened:
			tip.tooltip("")

func _on_button_pressed():
	if inventory:
		if inventory.visible:
			inventory.get_data(id)
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

	if signmenu:
		if signmenu.visible:
			if blur.state:
				for i in buildings.get_children():
					if i.name == signmenu.sign_name:
						i.set_sign_sprite(int(id))
						signmenu._close()
						var audio = AudioStreamPlayer.new()
						self.add_child(audio)
						audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
						audio.stream = load('res://assets/sounds/ui/click.ogg')
						audio.play()

	if trade_menu:
		if trade_menu.visible:
			if !Input.is_action_pressed("shift"):
				match tr_arg:
					tr_initator.PLAYER:
						if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.NONE:
							trade_menu.add_item_trade_window(id, tr_initator.PLAYER)
							trade_menu.updates_arrays()
							trade_menu.get_target_price()
							trade_menu.update_button_trade_window()
					tr_initator.TRADER:
						if trade_menu.initiator == trade_menu.initiators.TRADER || trade_menu.initiator == trade_menu.initiators.NONE:
							trade_menu.add_item_trade_window(id, tr_initator.TRADER)
							trade_menu.updates_arrays()
							trade_menu.get_target_price()
							trade_menu.update_button_trade_window()
					tr_initator.NONE:
						if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.TRADER:
							trade_menu.remove_item_trade_window(id)
							if trade_menu.initiator == trade_menu.initiators.TRADER:
								trade_menu.updates_arrays()
							trade_menu.update_button_trade_window()
							trade_menu.get_target_price()
					_:
						pass
			else:
				match tr_arg:
					tr_initator.PLAYER:
						if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.NONE:
							trade_menu.set_item_trade_window(id, tr_initator.PLAYER, amount/4)
							trade_menu.updates_arrays()
							trade_menu.get_target_price()
							trade_menu.update_button_trade_window()
					tr_initator.TRADER:
						if trade_menu.initiator == trade_menu.initiators.TRADER || trade_menu.initiator == trade_menu.initiators.NONE:
							trade_menu.set_item_trade_window(id, tr_initator.TRADER, amount/4)
							trade_menu.updates_arrays()
							trade_menu.get_target_price()
							trade_menu.update_button_trade_window()
					tr_initator.NONE:
						if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.TRADER:
							var half = round(trade_menu.trade_content[id]["amount"]/4)
							trade_menu.remove_item_trade_window(id, half)
							if trade_menu.initiator == trade_menu.initiators.TRADER:
								trade_menu.updates_arrays()
							trade_menu.update_button_trade_window()
							trade_menu.get_target_price()
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

	if composterMenu:
		if composterMenu.visible:
			if composterMenu.current_node:
				if !composterMenu.current_node.composting:
					if cmpst_type == 0:
						if !Input.is_action_pressed("shift"):
							composterMenu.add_item_compost(id, 1)
							composterMenu.check_state_button()
						else:
							composterMenu.add_item_compost(id, round(amount/4))
							composterMenu.check_state_button()
					else:
						if !Input.is_action_pressed("shift"):
							composterMenu.remove_item_compost(id, 1)
							composterMenu.check_state_button()
						else:
							composterMenu.remove_item_compost(id, round(amount/4))
							composterMenu.check_state_button()
					var audio = AudioStreamPlayer.new()
					self.add_child(audio)
					audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
					audio.stream = load('res://assets/sounds/ui/click.ogg')
					audio.play()
	
	if stoneMenu:
		if stoneMenu.visible:
			if !stoneMenu.target_node.inProcessed:
				stoneMenu.add_item(id)
				stoneMenu.check_button_state()
				var audio = AudioStreamPlayer.new()
				self.add_child(audio)
				audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
				audio.stream = load('res://assets/sounds/ui/click.ogg')
				audio.play()

	if sawmillMenu:
		if sawmillMenu.visible:
			sawmillMenu.add_item(id)
			sawmillMenu.update_button()
			var audio = AudioStreamPlayer.new()
			self.add_child(audio)
			audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
			audio.stream = load('res://assets/sounds/ui/click.ogg')
			audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()