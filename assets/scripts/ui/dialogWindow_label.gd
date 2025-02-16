extends Label

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var npcHeader:Label = get_node('/root/'+main+'/UI/Interactive/DialogWindow/MarginContainer/Panel/VBoxContainer/MarginContainer/Label')
@onready var buttonContainer:VBoxContainer = get_node('/root/'+main+'/UI/Interactive/DialogWindow/MarginContainer/Panel/VBoxContainer/MarginContainer2/Answers/MarginContainer/HBoxContainer')
@onready var specialButton:PackedScene = load('res://assets/nodes/ui/dialog_window_button.tscn')
@onready var timer:Timer = get_node('/root/'+main+'/UI/Interactive/DialogWindow/Timer')

var mainStringContent:Array[String]
var buttonCaptionsContent:Dictionary
var buttonTypeContent:Dictionary
var text_to_print:String
var print_speed:float = 0.01
var current_char_index:int = 0
var char_index:int = 0

func setDialogText(npcCaption:String, content:Array[String], buttonsCaption:Dictionary, buttonFunc:Dictionary) -> void:
	npcHeader.text = npcCaption
	mainStringContent = content
	buttonCaptionsContent = buttonsCaption
	buttonTypeContent = buttonFunc
	text_to_print = mainStringContent[char_index]
	if buttonsCaption.size() > 0:
		for child in buttonContainer.get_children():
			buttonContainer.remove_child(child)
		var captions = buttonCaptionsContent[char_index]
		var funcs = buttonFunc[char_index]
		for i in range(captions.size()):
			var button = specialButton.instantiate()
			button.text = captions[i]
			button.type = funcs[i]
			buttonContainer.add_child(button)
	add_child(timer)
	timer.wait_time = print_speed
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	start_printing()

func nextCaption() -> void:
	if char_index < mainStringContent.size()-1:
		char_index += 1
		text_to_print = mainStringContent[char_index]
		updateButtons()
		start_printing()

func updateButtons() -> void:
	for child in buttonContainer.get_children():
		buttonContainer.remove_child(child)
	if buttonCaptionsContent.has(char_index):
		var captions = buttonCaptionsContent[char_index]
		var funcs = buttonTypeContent[char_index]
		for i in range(captions.size()):
			var button = specialButton.instantiate()
			button.text = captions[i]
			button.type = funcs[i]
			buttonContainer.add_child(button)

func start_printing() -> void:
	text = ""
	current_char_index = 0
	timer.start()

func _on_timer_timeout() -> void:
	if current_char_index < text_to_print.length():
		text += text_to_print[current_char_index]
		current_char_index += 1
	else:
		timer.stop()