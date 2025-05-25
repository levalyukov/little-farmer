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
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

const maximum = 9999


enum trader_initator {NONE, PLAYER, TRADER}
var trader_arg:int = 0
var compost_type:int = 0

var item_id
var item_amount:int
var item_caption:String = ''

func set_data(id, amount:int, icon:CompressedTexture2D, caption:String) -> void:
	item_id = id
	item_amount = amount
	item_caption = caption
	$Button/Icon.texture = icon
	if item_amount > 1:
		$Button/Amount.visible = true
		if $Button/Amount:
			$Button/Amount.text = "x"+str(item_amount)
		if item_amount >= maximum:
			$Button/item_amount.text = "x"+str(maximum)
	else:
		$Button/Amount.visible = false

func _on_button_mouse_entered():
	if cursor: cursor.set_cursor(cursor.states.ACTIVE)
	tip.tooltip(tr(item_caption))

func _on_button_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	tip.tooltip()

func _on_button_pressed():
	if inventory:
		if inventory.visible:
			inventory.get_data(item_id)

	if signmenu:
		if signmenu.visible:
			if blur.state:
				for i in buildings.get_children():
					if i.name == signmenu.sign_name:
						i.set_sign_sprite(int(item_id))
						signmenu._close()

	if trade_menu:
		if trade_menu.visible:
			if !Input.is_action_pressed("shift"):
				match trader_arg:
					trader_initator.PLAYER:
						if !trade_menu.onlyPurchase:
							if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.NONE:
								trade_menu.add_item_trade_window(item_id, trader_initator.PLAYER)
								trade_menu.updates_arrays()
								trade_menu.get_target_price()
								trade_menu.update_button_trade_window()
					trader_initator.TRADER:
						if trade_menu.initiator == trade_menu.initiators.TRADER || trade_menu.initiator == trade_menu.initiators.NONE:
							trade_menu.add_item_trade_window(item_id, trader_initator.TRADER)
							trade_menu.updates_arrays()
							trade_menu.get_target_price()
							trade_menu.update_button_trade_window()
					trader_initator.NONE:
						if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.TRADER:
							trade_menu.remove_item_trade_window(item_id)
							if trade_menu.initiator == trade_menu.initiators.TRADER:
								trade_menu.updates_arrays()
							trade_menu.update_button_trade_window()
							trade_menu.get_target_price()
			else:
				match trader_arg:
					trader_initator.PLAYER:
						if !trade_menu.onlyPurchase:
							if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.NONE:
								trade_menu.set_item_trade_window(item_id, trader_initator.PLAYER, item_amount/4)
								trade_menu.updates_arrays()
								trade_menu.get_target_price()
								trade_menu.update_button_trade_window()
					trader_initator.TRADER:
						if trade_menu.initiator == trade_menu.initiators.TRADER || trade_menu.initiator == trade_menu.initiators.NONE:
							trade_menu.set_item_trade_window(item_id, trader_initator.TRADER, item_amount/4)
							trade_menu.updates_arrays()
							trade_menu.get_target_price()
							trade_menu.update_button_trade_window()
					trader_initator.NONE:
						if trade_menu.initiator == trade_menu.initiators.PLAYER || trade_menu.initiator == trade_menu.initiators.TRADER:
							trade_menu.remove_item_trade_window(item_id, round(item_amount/4))
							if trade_menu.initiator == trade_menu.initiators.TRADER:
								trade_menu.updates_arrays()
							trade_menu.update_button_trade_window()
							trade_menu.get_target_price()

	if composterMenu:
		if composterMenu.visible:
			if composterMenu.current_node:
				if !composterMenu.current_node.composting:
					if compost_type == 0:
						if !Input.is_action_pressed("shift"):
							composterMenu.add_item_compost(item_id, 1)
							composterMenu.check_state_button()
						else:
							composterMenu.add_item_compost(item_id, round(item_amount/4))
							composterMenu.check_state_button()
					else:
						if !Input.is_action_pressed("shift"):
							composterMenu.remove_item_compost(item_id, 1)
							composterMenu.check_state_button()
						else:
							composterMenu.remove_item_compost(item_id, round(item_amount/4))
							composterMenu.check_state_button()
	
	if stoneMenu:
		if stoneMenu.visible:
			if !stoneMenu.target_node.inProcessed:
				stoneMenu.add_item(item_id)
				stoneMenu.check_button_state()

	if sawmillMenu:
		if sawmillMenu.visible:
			sawmillMenu.add_item(item_id)
			sawmillMenu.update_button()
			sawmillMenu.update_icon_log()
			
	_play_sound('ui/click')

func _play_sound(path_ogg:String) -> void:
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/'+path_ogg+'.ogg')
	audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()
