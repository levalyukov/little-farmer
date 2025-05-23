extends Control

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")

@onready var header:Label = $Container/Panel/VBox/HeaderMargin/Label
@onready var description:Label = $Container/Panel/VBox/AboutMargin/VBoxContainer/Label
@onready var cutButton:Button = $Container/Panel/VBox/AboutMargin/VBoxContainer/MarginContainer/cutButton
@onready var logIcon:TextureRect = $Container/Panel/VBox/SlotsMargin/MarginContainer/HBoxContainer/OreContainer/TextureRect
@onready var logButton:Button = $Container/Panel/VBox/SlotsMargin/MarginContainer/HBoxContainer/OreContainer/removeLog
@onready var logAmount:Label = $Container/Panel/VBox/SlotsMargin/MarginContainer/HBoxContainer/OreContainer/LabelAmount
@onready var plankIcon:TextureRect = $Container/Panel/VBox/SlotsMargin/MarginContainer/HBoxContainer/IgnorContainer/TextureRect
@onready var plankButton:Button = $Container/Panel/VBox/SlotsMargin/MarginContainer/HBoxContainer/IgnorContainer/GetPlank
@onready var plankAmount:Label = $Container/Panel/VBox/SlotsMargin/MarginContainer/HBoxContainer/IgnorContainer/LabelAmount
@onready var itemsContainer:GridContainer = $Container/Panel/VBox/InventoryMargin/MarginContainer/ScrollContainer/GridContainer
@onready var anim:AnimationPlayer = $AnimationPlayer

var current_node:Node2D = null
var opened:bool = false
var items:Object = Items.new()
var current_slot_index:int = 0
var slots_to_create:Array = []

func _ready():
	window()

func _process(_delta):
	if visible && (slots_to_create.size() > 0 && current_slot_index < slots_to_create.size()):
		for i in range(1):
			if current_slot_index < slots_to_create.size():
				item_create(slots_to_create[current_slot_index])
				current_slot_index += 1
			else:
				break
	else:
		set_process(false)

func update_icon_log() -> void:
	if current_node:
		if current_node.logAmount > 0:
			logAmount.text = 'x'+str(current_node.logAmount)
			logIcon.modulate =  Color(1, 1, 1)
			plankIcon.modulate =  Color(1, 1, 1)
			plankAmount.text = 'x'+str(current_node.logAmount*5)
		else:
			logAmount.text = ''
			plankAmount.text = ''
			logIcon.modulate =  Color(0.8, 0.8, 0.8, 0.49)
			plankIcon.modulate =  Color(0.8, 0.8, 0.8, 0.49)

func open(node:Node2D) -> void:
	opened = true
	anim.play('open')
	blur.blur(true)
	get_menu_inventory()
	header.text = tr("sawmill_menu.caption")
	description.text = tr("sawmill_menu.description")
	cutButton.text = tr('sawmill_menu.button')
	if node:
		current_node = node
	window()

func close() -> void:
	opened = !true
	anim.play('close')
	blur.blur(false)
	clear_menu_inventory()
	current_node.logID = null
	current_node.logAmount = 0
	current_node = null
	
func window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_close_button_pressed():
	close()
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/click.ogg')
	audio.play()

func _on_close_button_mouse_entered():
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/hover.ogg')
	audio.play()

func item_create(item_id) -> void:
	var slot = inventory.node.instantiate()
	if inventory.inventory_items.has(item_id):
		if inventory.inventory_items[item_id]["amount"] > 0:
			var item_icon = items.content[int(item_id)]["icon"]
			var item_caption = items.content[int(item_id)]["caption"]
			var item_amount = inventory.inventory_items[item_id]["amount"]
			itemsContainer.add_child(slot)
			slot.set_data(
				item_id, 
				item_amount,
				item_icon,
				item_caption
			)

func get_menu_inventory() -> void:
	clear_menu_inventory()
	for i in inventory.inventory_items:
		if items.content.has(int(i)):
			if int(i) == 1:
				slots_to_create.append(i)
	set_process(true)

func clear_menu_inventory():
	if itemsContainer.get_children() != []:
		for i in itemsContainer.get_children():
			itemsContainer.remove_child(i)

func add_item(itemID) -> void:
	if current_node:
		if inventory.inventory_items.has(itemID):
			if inventory.inventory_items[itemID].has('amount'):
				if current_node.logAmount + 1 <= inventory.inventory_items[itemID]['amount']:
					current_node.logAmount += 1
					current_node.logID = itemID

func update_button() -> void:
	if current_node.logAmount > 0\
	&& current_node.logAmount <= inventory.inventory_items[current_node.logID]['amount']:
		cutButton.disabled = false
	else:
		cutButton.disabled = !false

func _on_remove_log_pressed():
	if current_node:
		if inventory.inventory_items.has(current_node.logID):
			if current_node.logAmount > 0:
				current_node.logAmount -= 1
			else:
				current_node.logID = 0
				current_node.logAmount = 0
			update_button()

func _on_cut_button_pressed():
	if inventory.inventory_items.has(current_node.logID):
		if current_node.logAmount > 0:
			if current_node.logAmount <= inventory.inventory_items[current_node.logID]['amount']:
				inventory.subject_item(current_node.logID, current_node.logAmount)
				inventory.add_item(2,current_node.logAmount*5)
				var audio = AudioStreamPlayer.new()
				self.add_child(audio)
				audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
				audio.stream = load('res://assets/sounds/ui/click.ogg')
				audio.play()
				var _audio = AudioStreamPlayer.new()
				self.add_child(_audio)
				_audio.connect("finished", Callable(self, "_on_audio_finished").bind(_audio))
				_audio.stream = load('res://assets/sounds/buildings/sawmill.ogg')
				_audio.play()
				current_node.logID = null
				current_node.logAmount = 0
				update_button()
				get_menu_inventory()
				update_icon_log()

func _on_cut_button_mouse_entered():
	if !cutButton.disabled:
		var audio = AudioStreamPlayer.new()
		self.add_child(audio)
		audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
		audio.stream = load('res://assets/sounds/ui/hover.ogg')
		audio.play()

func _on_audio_finished(node) -> void:
	node.queue_free()
