extends Button

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var dialogWindow:Control = get_node('/root/'+main+'/UI/Interactive/DialogWindow/')
@onready var mainLabel:Label = get_node('/root/'+main+'/UI/Interactive/DialogWindow/MarginContainer/Panel/VBoxContainer/MainText/VBoxContainer/MarginContainer2/Label')
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var trade:Control = get_node('/root/'+main+'/UI/Interactive/TradeMenu')
@onready var blueprintsShop:Control = get_node("/root/"+main+"/UI/Interactive/BlueprintsShop")

var type:int
enum TYPES {EXIT, NEXT, OPEN_TRADE, OPEN_BLUEPRINT_SHOP}

func _on_pressed():
	match type:
		TYPES.EXIT:
			dialogWindow.dialogWindowClose()
			if blur:
				blur.blur(false)
		TYPES.NEXT:
			mainLabel.nextCaption()
		TYPES.OPEN_BLUEPRINT_SHOP:
			dialogWindow.dialogWindowClose()
			blueprintsShop.open()
		TYPES.OPEN_TRADE:
			dialogWindow.dialogWindowClose()
			trade.open_trade_menu(dialogWindow.trade_id)
		_:
			return
