extends Control

@onready var mainLabel:Label = $MarginContainer/Panel/VBoxContainer/MainText/VBoxContainer/MarginContainer2/Label
@onready var buttonContainer = 

func _ready():
	dialogWindow('GoodBye, World!', ['Next', 'Exit'])

func dialogWindow(mainText:String, buttonsCaption:Array[String]):
	mainLabel.setDialogText(mainText)
	if buttonsCaption.size() > 0:
		for i in buttonsCaption:
			var button = Button.new()
			button.text = i

