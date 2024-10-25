extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var button_script:Button = get_node("/root/"+main+"/UI/Interactive/Mailbox/Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/ButtonContainer/GetItems")
@onready var letter_node:PackedScene = load("res://assets/nodes/ui/interactive/mail/letter.tscn")
@onready var slot:PackedScene = inventory.node

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var content_scroll:ScrollContainer = $Panel/HBoxContainer/ContentScroll
@onready var letters_container:VBoxContainer = $Panel/HBoxContainer/LettersScroll/VBoxContainer
@onready var content_container:VBoxContainer = $Panel/HBoxContainer/ContentScroll/VBoxContainer
@onready var items_hbox:HBoxContainer = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/HBoxContainer
@onready var items_container:GridContainer = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/HBoxContainer/Items/GridContainer
@onready var items_block:MarginContainer = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterItems
@onready var header_label:Label = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterHeader/Title
@onready var description_label:Label = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterContent/Text
@onready var author_label:Label = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterAuthor/Author
@onready var attached_items_label:Label = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/LabelContainer/Label
@onready var button:Button = $Panel/HBoxContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/ButtonContainer/GetItems

var item:Object = Items.new()
var menu:bool = false
 
var index
var letter_name
var letters:Dictionary = {}

func _process(_delta):
	if Input.is_action_just_pressed("pause")\
	and menu:
		close()

func _ready():
	check_window()
	reset_data()
	delete_letters(letters_container)

	letter(
		"Доброе начало",
		"Приветствую тебя! Видя, что ты начинаешь свое дело, решил я помочь тебе на первых шагах. Знаю, что всегда тяжело сделать первый шаг, особенно когда дело касается строительства. Поэтому собрал немного стройматериалов — доски, гвозди и прочее, что, быть может, понадобится тебе на старте.\n\nПусть этот небольшой подарок станет твоей поддержкой и толчком к тому, чтобы начать строить что-то полезное на твоей ферме. Если знаешь, с чего начать — вперед! Если еще думаешь, не торопись, материалы подождут. Главное — не бойся начинать.\n\nЕсли понадобится совет или помощь, не стесняйся обращаться — всегда буду рад помочь!",
		"С уважением,\nПлотник Гюнтер",
		0,
		{
			1:{"amount":100},
			2:{"amount":100},
			3:{"amount":100},
		}
	)

	letter(
		"Скромный подарок",
		"Поздравляем с началом вашего фермерского пути! Мы рады, что вы выбрали это важное и благородное дело. Чтобы помочь вам сделать первые шаги, мы подготовили для вас небольшой подарок. Надеемся, что он окажется полезным и облегчит вам начало работы.\n\n\nЖелаем вам успехов, крепкого здоровья и хороших урожаев! Пусть ваше начинание принесет много радости и удовлетворения.",
		"Мэр города",
		0,
		{
			13:{"amount":36},
			14:{"amount":36},
			15:{"amount":36},
			16:{"amount":36},
		}
	)

	letter(
		"Воздаяние долга",
		"С великим сокрушением серца сего пишу к тебе, ибо суждено было мне долг сей воздать твоему достославному деду, да не поспел я в предначертанный час. Сей долг, должонный мне, я ныне передаю тебе, внуче его, дабы продолжить договор, коий был меж мною и твоим дедушкой, человеком чести и совести крепкой.\n\nПрими же от меня сие серебро, не токмо как долг уплаченный, но и как знак почтения моего к роду вашему. Нехай оно сослужит тебе добрую службу и поможет в делах твоих, как и некогда помогло оно мне в трудные дни.\n\nМолю Господа даровать тебе здравие и долголетие. А ежели нужда какая придет, то ведай, что всегда рад буду помочь и подмогу подать.",
		"Остаюсь с низким поклоном, твой преданный сосед Тихомир",
		10000,
		{}
	)

func letter(header:String, description:String = "", author:String = "", money:int = 0, items:Dictionary = {}) -> void:
	var key = letters.size() + 1
	if header != "":
		letters[key] = {}
		letters[key]["status"] = "unread"
		letters[key]["header"] = header
		letters[key]["description"] = description
		letters[key]["author"] = author
		letters[key]["money"] = money
		letters[key]["items"] = {}
		if items != {}:
			check_all_keys(key, items)

func check_all_keys(id, dictionary:Dictionary) -> void:
	for key in dictionary.keys():
		if !dictionary[key].has("amount"):
			if !letters[id]["items"].has(key):
				letters[id]["items"][key] = {}
			letters[id]["items"][key]["amount"] = 1
		else:
			letters[id]["items"][key] = dictionary[key]

func get_data(letterID) -> void:
	index = check_letterID(letterID)
	content_scroll.scroll_vertical = 0
	if letters.has(index):
		letter_delete_items(items_container)
		if letters[index].has("status"):
			if letters[index]["status"] == "unread":
				letters[index]["status"] = "readed"
		else:
			data.debug("The 'status' is not a string.", "error")

		if letters[index].has("header"):
			if typeof(letters[index]["header"]) == TYPE_STRING:
				header_label.text = letters[index]["header"]
				header_label.visible = true
			else:
				data.debug("The 'header' is not a string.", "error")
		else:
			header_label.visible = false

		if letters[index].has("description"):
			if typeof(letters[index]["description"]) == TYPE_STRING:
				description_label.text = letters[index]["description"]
				description_label.visible = true
			else:
				print_debug("The 'description_label' is not a string.", "error")
		else:
			description_label.visible = false

		if letters[index].has("author"):
			if typeof(letters[index]["author"]) == TYPE_STRING:
				author_label.text = "- " + letters[index]["author"]
				author_label.visible = true
			else:
				data.debug("The 'author' is not a string.", "error")
		else:
			author_label.visible = false

		if (letters[index].has("items") or letters[index].has("money"))\
		and (letters[index]["items"] != {} or letters[index]["money"] != 0):
			items_block.visible = true

			if (letters[index]["items"] != {} || letters[index]["money"] != 0):
				button.text = tr("get_all_items.mail")
				if letters[index]["items"] != {}:
					items_hbox.visible = true
					for i in letters[index]["items"]:
						if typeof(letters[index]["items"][i]) == TYPE_DICTIONARY\
						&& letters[index]["items"][i].has("amount"):
							if letters[index]["items"][i]["amount"] > 0:
								letter_create_items(
									int(i), 
									int(letters[index]["items"][i]["amount"]), 
									items_container, 
									slot
								)
							else:
								letters[index]["items"][i].erase(index)

				if !letters[index].has("collected"):
					button.visible = true
					if storage.object.has(storage.level):
						if storage.object[storage.level].has("slots"):
							if storage.object[storage.level]["slots"] - inventory.get_all_items() >= get_letter_items():
								button_script.state(false)
							else:
								button_script.state(true)
						else:
							data.debug("It is impossible to get the 'slots' key from the object", "error")
					else:
						data.debug("It is impossible to get the 'level' key from the object", "error")
				else:
					button.visible = false

			if letters[index]["money"] > 0:
				var nested = tr("letter.nested")
				var money = tr("letter.money")
				if letters[index]["money"] > balance.maximum:
					letters[index]["money"] = balance.maximum
				attached_items_label.text = nested + ": " + str(balance.format(letters[index]["money"])) + " " + money
				attached_items_label.visible = true
			else:
				var attached_items = tr("letter.attached_items")
				attached_items_label.text = attached_items + ":"
				attached_items_label.visible = true
		else:
			items_block.visible = false
	else:
		data.debug("Invalid index: " + str(index), "error")

func check_letterID(letterID):
	for i in letters:
		if typeof(i) == TYPE_INT:
			return int(letterID)
		if typeof(i) == TYPE_STRING:
			return str(letterID)

func get_all_items(id, dictionary:Dictionary) -> void:
	if dictionary[id].has("items"):
		if dictionary[id]["items"] != {}:
			if check_letter_item(1, id, dictionary):
				check_letter_item(2, id, dictionary)

	if dictionary[id].has("money"):
		balance.add_money(dictionary[id]["money"])

	dictionary[id]["collected"] = true
	button.visible = false

func check_letter_item(check:int, letterID, dictionary:Dictionary):
	match check:
		1:
			if dictionary[letterID].has("items"):
				for key in dictionary[letterID]["items"]:
					if item.content.has(int(key)):
						return true
			return false
		2:
			for key in dictionary[letterID]["items"].keys():
				if item.content.has(int(key)):
					if inventory.inventory_items.has(int(key)):
						inventory.add_item(int(key), int(dictionary[letterID]["items"][key]["amount"]))
					elif inventory.inventory_items.has(str(key)):
						inventory.add_item(str(key), int(dictionary[letterID]["items"][key]["amount"]))
					else:
						inventory.add_item(int(key), int(dictionary[letterID]["items"][key]["amount"]))
				else:
					data.debug("Incorrect subject ID ("+str(key)+"): Such a subject does not exist in the main subject dictionary.", "error")

func create_letters(dictionary:Dictionary, node:PackedScene, parent:VBoxContainer) -> void:
	for i in dictionary:
		var object = node.instantiate()
		parent.add_child(object)
		object.set_data(i, dictionary[i]["header"])
		if letters[i].has("status"):
			match letters[i]["status"]:
				"unread":
					var letter_icon = object.icon
					_update_letter_icon(object, letter_icon, "unread")
				"readed":
					var letter_icon = object.icon
					_update_letter_icon(object, letter_icon, "readed")
				_:
					data.debug("Invalid letter status: "+str(letters[i]["status"]), "error")
		else:
			letters[i]["status"] = "unread"
			data.debug("The 'status' key was created for the letter with the index: "+str(i), "info")

func _update_letter_icon(object, letter_icon, status:String) -> void:
	match status:
		"readed":
			letter_icon.texture = object.sprites["readed"]
		"unread":
			letter_icon.texture = object.sprites["unread"]
		_:
			data.debug("Invalid letter status: "+str(status),"error")

func delete_letters(parent:VBoxContainer) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func get_letter_items():
	var item_counter:int = 0
	for i in items_container.get_children():
		item_counter+=1
	return item_counter

func letter_create_items(id:int, amount:int, parent:GridContainer, node:PackedScene) -> void:
	if item.content.has(id):
		var object = node.instantiate()
		parent.add_child(object)
		object.set_data(id, amount)
	else:
		data.debug("Invalid item ID: " + str(id), "error")
		
func letter_delete_items(parent:GridContainer) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func letters_load(content:Dictionary):
	letters = content

func get_letters() -> Dictionary:
	return letters

func reset_data() -> void:
	header_label.text = ""
	description_label.text = ""
	author_label.text = ""
	items_block.visible = false

func open() -> void:
	menu = true
	pause.other_menu = true
	blur.blur(true)
	anim.play("open")
	create_letters(letters, letter_node, letters_container)
	
func close() -> void:
	menu = false
	pause.other_menu = false
	self.index = 0
	blur.blur(false)
	anim.play("close")
	delete_letters(letters_container)

func check_window() -> void:
	visible = menu

func _on_get_items_pressed():
	if !button_script.button:
		if button.visible:
			get_all_items(index, letters)
	else:
		var full_inventory_error = tr("full_inventory.error")
		notice.create_notice(full_inventory_error, "error")

func _on_close_pressed() -> void:
	if blur.state:
		close()
