extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var modal:Control = get_node("/root/"+main+"/UI/Feedback/Modal")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/Storage")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var button_script:Button = get_node("/root/"+main+"/UI/Interactive/Mailbox/Main/MailContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/ButtonContainer/GetItems")
@onready var letter_node:PackedScene = load("res://assets/nodes/ui/interactive/mail/letter.tscn")
@onready var slot:PackedScene = inventory.node

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var content_scroll:ScrollContainer = $Main/MailContainer/ContentScroll
@onready var letters_container:VBoxContainer = $Main/MailContainer/LettersScroll/VBoxContainer
@onready var content_container:VBoxContainer = $Main/MailContainer/ContentScroll/VBoxContainer
@onready var items_hbox:HBoxContainer = $Main/MailContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/HBoxContainer
@onready var items_container:GridContainer = $Main/MailContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/HBoxContainer/Items/GridContainer
@onready var items_block:MarginContainer = $Main/MailContainer/ContentScroll/VBoxContainer/LetterItems
@onready var header_label:Label = $Main/MailContainer/ContentScroll/VBoxContainer/LetterHeader/Title
@onready var description_label:Label = $Main/MailContainer/ContentScroll/VBoxContainer/LetterContent/Text
@onready var author_label:Label = $Main/MailContainer/ContentScroll/VBoxContainer/LetterAuthor/Author
@onready var attached_items_label:Label = $Main/MailContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/LabelContainer/Label
@onready var button:Button = $Main/MailContainer/ContentScroll/VBoxContainer/LetterItems/VBoxContainer/ButtonContainer/GetItems

@onready var mail_remove_container:MarginContainer = $Main/MailContainer/ContentScroll/VBoxContainer/LetterManipulationButton
@onready var mail_remove_button:Button = $Main/MailContainer/ContentScroll/VBoxContainer/LetterManipulationButton/MailRemove
@onready var mail_manipulation_buttons:HBoxContainer = $Main/MailManipulationButtons
@onready var remove_all_readed_button:Button = $Main/MailManipulationButtons/MarginContainer/DeleteAllReadedLetters

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
	delete_letters()

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
					change_state_mail_remove_button(false)
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
					change_state_mail_remove_button(true)
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
			change_state_mail_remove_button(true)
			items_block.visible = false
	else:
		data.debug("Invalid index: " + str(index), "error")
	update_state_mail_manipulation_button()

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
	change_state_mail_remove_button(true)

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

func create_letters() -> void:
	for i in letters:
		var object = letter_node.instantiate()
		letters_container.add_child(object)
		object.set_data(i, letters[i]["header"])
		if letters[i].has("status"):
			match letters[i]["status"]:
				"unread":
					var letter_icon = object.icon
					update_letter_icon(object, letter_icon, "unread")
				"readed":
					var letter_icon = object.icon
					update_letter_icon(object, letter_icon, "readed")
				_:
					data.debug("Invalid letter status: "+str(letters[i]["status"]), "error")
		else:
			letters[i]["status"] = "unread"
			data.debug("The 'status' key was created for the letter with the index: "+str(i), "info")

func update_letter_icon(object, letter_icon, status:String) -> void:
	match status:
		"readed":
			letter_icon.texture = object.sprites["readed"]
		"unread":
			letter_icon.texture = object.sprites["unread"]
		_:
			data.debug("Invalid letter status: "+str(status),"error")

func delete_letters() -> void:
	for child in letters_container.get_children():
		letters_container.remove_child(child)
		child.queue_free()

func get_letter_items() -> int:
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

func letters_load(content:Dictionary) -> void:
	letters = content

func get_letters() -> Dictionary:
	return letters

func reset_data() -> void:
	var string_header_mail:String = tr("mail.header")
	if letters != {}:
		header_label.text = string_header_mail
		if get_all_unreaded_letters() > 0:
			description_label.text = tr("mail.description_check_your_mail:") + " " + str(get_all_unreaded_letters())
		else:
			description_label.text = tr("mail.default_description")
	else:
		header_label.text = string_header_mail
		description_label.text = tr("mail.description_no_letters")
	author_label.text = ""
	items_block.visible = false
	change_state_mail_remove_button(false)

func open() -> void:
	menu = true
	pause.other_menu = true
	blur.blur(true)
	anim.play("open")
	reset_data()
	create_letters()
	change_state_mail_remove_button(false)
	update_mail_manipulation_button()
	update_state_mail_manipulation_button()
	
func close() -> void:
	menu = false
	pause.other_menu = false
	self.index = 0
	blur.blur(false)
	anim.play("close")
	delete_letters()

func check_window() -> void:
	visible = menu

func _on_get_items_pressed() -> void:
	if !button_script.button:
		if button.visible:
			get_all_items(index, letters)
	else:
		var full_inventory_error = tr("full_inventory.error")
		notice.create_notice(full_inventory_error, "error")

func _on_close_pressed() -> void:
	if blur.state:
		close()

# Mail Manipulation Buttons
func _on_mail_remove_pressed() -> void:
	if mail_remove_button.visible:
		mail_remove(index)

func _on_delete_all_readed_letters_pressed() -> void:
	remove_all_readed_letters()

func change_state_mail_remove_button(state:bool) -> void:
	mail_remove_container.visible = state

func mail_remove(letter_id) -> void:
	letters.erase(letter_id)
	mail_update()
	modal.modal_create(modal.header_string, "mail.it_was_deleted")

func remove_all_readed_letters() -> void:
	var ids_remove:Array[int] = []
	var deleted:int = 0
	for id in letters:
		if letters[id].has("status"):
			if letters[id]["status"] == "readed":
				if letters[id].has("items") && letters[id]["items"] != {}\
				|| letters[id].has("money") && letters[id]["money"] > 0:
						if letters[id].has("collected"):
							if letters[id]["collected"] == true:
								ids_remove.append(id)
				else:
					ids_remove.append(id)

	if ids_remove != []:
		for id in ids_remove:
			deleted+=1
			letters.erase(id)
		mail_update()
		modal.modal_create(modal.header_string, "mail.it_was_deleted: " + str(deleted))
	else:
		modal.modal_create(modal.header_string, "Letters with unassembled items were not deleted")

func get_all_unreaded_letters() -> int:
	var count_unreaded:int = 0
	for id in letters:
		if letters[id].has("status"):
			if letters[id]["status"] == "unread":
				count_unreaded+=1
	return count_unreaded

func get_all_readed_letters() -> int:
	var count_readed:int = 0
	for id in letters:
		if letters[id].has("status"):
			if letters[id]["status"] == "readed":
				count_readed+=1
	return count_readed

func mail_update() -> void:
	reset_data()
	delete_letters()
	create_letters()
	update_mail_manipulation_button()
	update_state_mail_manipulation_button()

func update_mail_manipulation_button() -> void:
	if letters != {}:
		if !mail_manipulation_buttons.visible:
			mail_manipulation_buttons.visible = true
	else:
		if mail_manipulation_buttons.visible:
			mail_manipulation_buttons.visible = false

func update_state_mail_manipulation_button() -> void:
	if get_all_readed_letters() > 0:
		remove_all_readed_button.disabled = false
	else:
		remove_all_readed_button.disabled = true