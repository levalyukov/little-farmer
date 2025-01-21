extends Button

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var dialogWindow:Control = get_node('/root/'+main+'/UI/Interactive/DialogWindow/')
@onready var mainLabel:Label = get_node('/root/'+main+'/UI/Interactive/DialogWindow/MarginContainer/Panel/VBoxContainer/MainText/VBoxContainer/MarginContainer2/Label')
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var trade:Control = get_node('/root/'+main+'/UI/Interactive/TradeMenu')

var type:int
enum TYPES {EXIT, NEXT, OPEN_TRADE, OPEN_NOTE}

func _on_pressed():
	match type:
		TYPES.EXIT:
			dialogWindow.dialogWindowClose()
			if blur:
				blur.blur(false)
		TYPES.NEXT:
			mainLabel.nextCaption()
		TYPES.OPEN_NOTE:
			pass
		TYPES.OPEN_TRADE:
			dialogWindow.dialogWindowClose()
			trade.open_trade_menu()
		_:
			return