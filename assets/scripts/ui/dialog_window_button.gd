extends Button

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var dialogWindow:Control = get_node('/root/'+main+'/')
@onready var mainLabel:Label = get_node('/root/'+main+'/MarginContainer/Panel/VBoxContainer/MainText/VBoxContainer/MarginContainer2/Label')

var type:int
enum TYPES {EXIT, NEXT, OPEN_TRADE, OPEN_NOTE}

func _on_pressed():
	match type:
		TYPES.EXIT:
			dialogWindow.dialogWindowClose()
		TYPES.NEXT:
			mainLabel.nextCaption()
		TYPES.OPEN_NOTE:
			pass
		TYPES.OPEN_TRADE:
			pass
		_:
			return