extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var modal:Control = get_node("/root/"+main+"/UI/Feedback/Modal")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var storage:Node2D = get_node("/root/"+main+"/ConstructionManager/storage")
@onready var mailbox:Node2D = get_node("/root/"+main+"/ConstructionManager/mailbox")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var button_script:Button = get_node("/root/"+main+"/UI/Interactive/Mailbox/Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer/VBoxContainer/ButtonContainer/GetItems")
@onready var letter_node:PackedScene = load("res://assets/nodes/ui/interactive/mail/letter.tscn")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var slot:PackedScene = inventory.node

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var content_scroll:ScrollContainer = $Panel/HBoxContainer/LetterContent/ScrollContainer
@onready var letters_container:GridContainer = $Panel/HBoxContainer/LettersContainer/ScrollContainer/GridContainer
@onready var items_hbox:MarginContainer = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer
@onready var items_container:GridContainer = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer/VBoxContainer/ItemContainer/GridContainer
@onready var items_block:MarginContainer = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer/VBoxContainer/ItemContainer
@onready var header_label:Label = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/LetterHeader/Header
@onready var description_label:Label = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/LetterContent/Content
@onready var author_label:Label = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/LetterAuthor/Author
@onready var attached_items_label:RichTextLabel = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer/VBoxContainer/MoneyContainer/Label
@onready var button_container:MarginContainer = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer/VBoxContainer/ButtonContainer
@onready var button:Button = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ItemsContainer/VBoxContainer/ButtonContainer/GetItems
@onready var mail_manipulation_buttons:Button = $Panel/HBoxContainer/LetterContent/ScrollContainer/VBoxContainer/ManipulationButtons/MailRemove
@onready var mails_remove_button:Button = $Panel/DeleteAllReadedLetters

var audio = AudioStreamPlayer.new()
var item:Object = Items.new()
var opened:bool = false
 
var index
var letter_name
var letters:Dictionary = {}
var current_letter_index:int = 0
var letters_to_create:Array = []

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& !pause.paused\
	&& opened:
		close()

func _ready():
	check_window()
	reset_data()
	delete_letters()
	self.add_child(audio)
	if main:
		if main == "Farm":
			if data:
				if data.file_load(data.file.player):
					if data.file_load(data.file.player).has('indicator_mailbox'):
						GameLoader.mailbox_indicator = data.file_load(data.file.player)['indicator_mailbox']
						mailbox.check_indicator_state()

func _process(_delta) -> void:
	if visible:
		if letters_to_create.size() > 0 and current_letter_index < letters_to_create.size():
			for i in range(1):
				if current_letter_index < letters_to_create.size():
					create_letter(letters_to_create[current_letter_index])
					current_letter_index += 1
				else:
					break

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
		if items != {}: check_all_keys(key, items)
		if main == "Farm":
			var _audio = AudioStreamPlayer.new()
			self.add_child(_audio)
			_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
			_audio.stream = load('res://assets/sounds/ui/new_letter.ogg')
			_audio.play()
		if !opened:
			GameLoader.mailbox_indicator = true
			if mailbox:
				mailbox.check_indicator_state()
		else:
			delete_letters()
			create_all_letters()

func check_all_keys(id, dictionary:Dictionary) -> void:
	for key in dictionary.keys():
		if !dictionary[key].has("amount"):
			if !letters[id]["items"].has(key):
				letters[id]["items"][key] = {}
			letters[id]["items"][key]["amount"] = 1
		else:
			letters[id]["items"][key] = dictionary[key]

func get_data(letterID) -> void:
	reset_data()
	index = letterID
	content_scroll.scroll_vertical = 0
	if letters.has(index):
		letter_delete_items(items_container)
		if letters[index].has("status"):
			if letters[index]["status"] == "unread":
				letters[index]["status"] = "readed"

		if letters[index].has("header"):
			if typeof(letters[index]["header"]) == TYPE_STRING:
				header_label.text = tr(letters[index]["header"])
				header_label.visible = true
		else:
			header_label.visible = false

		if letters[index].has("description"):
			if typeof(letters[index]["description"]) == TYPE_STRING:
				description_label.text = tr(letters[index]["description"])
				description_label.visible = true
		else:
			description_label.visible = false

		if letters[index].has("author"):
			if typeof(letters[index]["author"]) == TYPE_STRING:
				author_label.text = "- " + tr(letters[index]["author"])
				author_label.visible = true
		else:
			author_label.visible = false

		if (letters[index].has("items") or letters[index].has("money"))\
		&& (letters[index]["items"] != {} or letters[index]["money"] != 0):
			items_hbox.visible = true
			if (letters[index]["items"] != {} || letters[index]["money"] != 0):
				button.text = tr("mail.button.get_all_items")
				if letters[index]["items"] != {}:
					items_block.visible = true
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
				if letters[index]["money"] > balance.maximum:
					letters[index]["money"] = balance.maximum
				attached_items_label.text = tr("mail.letter.investment") + ": [color=#ffce5e]" + str(balance.format(letters[index]["money"])) + " " + tr('money_symbol') + " " + "[/color]"
				attached_items_label.visible = true
			else:
				attached_items_label.text = tr("mail.letter.attached_items") + ":"
				attached_items_label.visible = true
		else:
			change_state_mail_remove_button(true)
			items_block.visible = false
	else:
		data.debug("Invalid index: " + str(index) + ' | godot.typeof: ' + str(typeof(index)), "error")
	update_state_mail_manipulation_button()

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

func create_letter(id) -> void:
	var object = letter_node.instantiate()
	letters_container.add_child(object)
	object.set_data(id, tr(letters[id]["header"]))
	if letters[id].has("status"):
		match letters[id]["status"]:
			"unread":
				var letter_icon = object.icon
				update_letter_icon(object, letter_icon, "unread")
			"readed":
				var letter_icon = object.icon
				update_letter_icon(object, letter_icon, "readed")
			_:
				data.debug("Invalid letter status: "+str(letters[id]["status"]), "error")
	else:
		letters[id]["status"] = "unread"
		data.debug("The 'status' key was created for the letter with the index: "+str(id), "info")

func create_all_letters() -> void:
	letters_to_create = []
	for i in letters:
		letters_to_create.append(i)
	current_letter_index = 0

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
	if letters != {}:
		header_label.text = tr("mail.ui.header")
		if get_all_unreaded_letters() > 0:
			description_label.text = tr("mail.ui.mailbox_has_unread_letters_text") + ": " + str(get_all_unreaded_letters())
		else:
			description_label.text = tr("mail.ui.mailbox_has_letters_text")
	else:
		header_label.text = tr("mail.ui.header")
		description_label.text = tr("mail.ui.mailbox_empty_text")
	author_label.text = ""
	items_hbox.visible = false
	change_state_mail_remove_button(false)

func open() -> void:
	opened = true
	pause.other_menu = true
	blur.blur(true)
	anim.play("open")
	reset_data()
	delete_letters()
	create_all_letters()
	change_state_mail_remove_button(false)
	update_mail_manipulation_button()
	update_state_mail_manipulation_button()
	GameLoader.mailbox_indicator = false
	if mailbox: mailbox.check_indicator_state()
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)
	if mails_remove_button: mails_remove_button.text = tr('mail.button.delete_read_ones')
	if audio:
		if !audio.is_playing():
			audio.stream = load('res://assets/sounds/ui/mailbox.ogg')
			audio.play()
	
func close() -> void:
	opened = false
	pause.other_menu = false
	self.index = 0
	blur.blur(false)
	anim.play("close")

func check_window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_get_items_pressed() -> void:
	if !button_script.button:
		if button.visible:
			var _audio = AudioStreamPlayer.new()
			self.add_child(_audio)
			_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
			_audio.stream = load('res://assets/sounds/ui/click.ogg')
			_audio.play()
			get_all_items(index, letters)
			if cursor:
				cursor.set_cursor(cursor.states.DEFAULT)
	else:
		var full_inventory_error = tr("mail.button.full_inventory_error")
		notice.create_notice(full_inventory_error, "error")

func _on_close_pressed() -> void:
	if blur.state:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/click.ogg')
		_audio.play()
		close()

# Mail Manipulation Buttons
func _on_mail_remove_pressed() -> void:
	if mails_remove_button.visible:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/click.ogg')
		_audio.play()
		mail_remove(index)

func _on_delete_all_readed_letters_pressed() -> void:
	var _audio = AudioStreamPlayer.new()
	self.add_child(_audio)
	_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
	_audio.stream = load('res://assets/sounds/ui/click.ogg')
	_audio.play()
	remove_all_readed_letters()

func change_state_mail_remove_button(state:bool) -> void:
	mail_manipulation_buttons.visible = state
	mail_manipulation_buttons.text = tr('mail.button.letter_remove')

func mail_remove(letter_id) -> void:
	letters.erase(letter_id)
	mail_update()
	modal.modal_create(tr('mail.ui.notification'), tr('mail.ui.letter_has_delete'))

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
		modal.modal_create(tr('mail.ui.notification'), tr("mail.ui.letters_was_delete") + ": " + str(deleted))
	else:
		modal.modal_create(tr('mail.ui.notification'), tr('mail.ui.letters_unreceived_items_not_delete.text'))

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
	create_all_letters()
	update_mail_manipulation_button()
	update_state_mail_manipulation_button()

func update_mail_manipulation_button() -> void:
	if letters != {}:
		if !mails_remove_button.visible:
			mails_remove_button.visible = true
	else:
		if mails_remove_button.visible:
			mails_remove_button.visible = false

func update_state_mail_manipulation_button() -> void:
	if get_all_readed_letters() > 0: mails_remove_button.disabled = false
	else: mails_remove_button.disabled = true

func _on_close_mouse_entered():
	var _audio = AudioStreamPlayer.new()
	self.add_child(_audio)
	_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
	_audio.stream = load('res://assets/sounds/ui/hover.ogg')
	_audio.play()
	if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_close_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_get_items_mouse_entered():
	if button.visible && !button.disabled:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/hover.ogg')
		_audio.play()
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_get_items_mouse_exited():
	if button.visible && !button.disabled:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_mail_remove_mouse_entered():
	if mail_manipulation_buttons.visible:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/hover.ogg')
		_audio.play()
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_mail_remove_mouse_exited():
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_delete_all_readed_letters_mouse_entered():
	if mails_remove_button.visible && !mails_remove_button.disabled:
		var _audio = AudioStreamPlayer.new()
		self.add_child(_audio)
		_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
		_audio.stream = load('res://assets/sounds/ui/hover.ogg')
		_audio.play()
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_delete_all_readed_letters_mouse_exited():
	if button.visible && !button.disabled:
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_audio_finished(node) -> void:
	node.queue_free()
