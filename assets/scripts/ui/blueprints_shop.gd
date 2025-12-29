extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var construct:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var mail:Control = get_node("/root/"+main+"/UI/Interactive/Mailbox")

@onready var buttonAllBlueprints:Button = $Panel/NavMenu/ButtonAllBlueprints
@onready var buttonNodes:Button = $Panel/NavMenu/ButtonBuildings
@onready var buttonTerrain:Button = $Panel/NavMenu/ButtonLandscape
@onready var buttonUpgrades:Button = $Panel/NavMenu/ButtonUpgrades

@onready var blueprintsIcon:TextureRect = $Panel/MarginContainer/HBoxContainer/BlueprintsInfo/NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/SpriteMargin/TextureRect
@onready var blueprintsHeader:Label = $Panel/MarginContainer/HBoxContainer/BlueprintsInfo/NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CaptionMargin/Caption
@onready var blueprintsDescription:RichTextLabel = $Panel/MarginContainer/HBoxContainer/BlueprintsInfo/NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/DescriptionMargin/Description
@onready var blueprintsPrice:RichTextLabel = $Panel/MarginContainer/HBoxContainer/BlueprintsInfo/NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/PriceMargin/Price
@onready var blueprintsBuy:Button = $Panel/MarginContainer/HBoxContainer/BlueprintsInfo/NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/BuyMargin/Button
@onready var blueprintsContainer:GridContainer = $Panel/MarginContainer/HBoxContainer/BlueprintsMargin/ScrollContainer/MarginContainer/BlueprintsContainer
@onready var blueprintsNode:PackedScene = load("res://assets/nodes/ui/interactive/construct/blueprint.tscn")
@onready var anim:AnimationPlayer = $AnimationPlayer
var blueprints:Object = BlueprintManager.new()
var opened:bool = false

var section:String = 'all'
var slots_to_create_terrains = []
var slots_to_create_nodes = []
var slots_to_create_upgrade = []

var slots_to_create_terrains_captions = []
var slots_to_create_nodes_captions = []
var slots_to_create_upgrade_captions = []

var current_slot_index_terrains = 0
var current_slot_index_nodes = 0
var current_slot_index_upgrade = 0

var blueprint_section:String = ""
var blueprint_index:int = 0
var blueprint_price:int = 0

func _ready():
	window()
	set_process(false)

func _process(_delta) -> void:
	if visible:
		# nodes
		if slots_to_create_nodes.size() > 0 && current_slot_index_nodes < slots_to_create_nodes.size():
			for i in range(1):
				if current_slot_index_nodes < slots_to_create_nodes.size():
					var blueprint = blueprintsNode.instantiate()
					blueprintsContainer.add_child(blueprint)
					blueprint.set_data("nodes", slots_to_create_nodes[current_slot_index_nodes])
					if check_construct_array('nodes', slots_to_create_nodes[current_slot_index_nodes]):
						if blueprints.content['nodes'][slots_to_create_nodes[current_slot_index_nodes]].has('trade_info'):
							if blueprints.content['nodes'][slots_to_create_nodes[current_slot_index_nodes]]['trade_info'].has('caption'):
								blueprint.disabled_button(true, tr('blueprints_shop.available'))
					current_slot_index_nodes += 1
				else:
					break
		# terrains
		if slots_to_create_terrains.size() > 0 && current_slot_index_terrains < slots_to_create_terrains.size():
			for i in range(1):
				if current_slot_index_terrains < slots_to_create_terrains.size():
					var blueprint = blueprintsNode.instantiate()
					blueprintsContainer.add_child(blueprint)
					blueprint.set_data("terrains", slots_to_create_terrains[current_slot_index_terrains])
					if check_construct_array('terrains', slots_to_create_terrains[current_slot_index_terrains]):
						if blueprints.content['terrains'][slots_to_create_terrains[current_slot_index_terrains]].has('trade_info'):
							if blueprints.content['terrains'][slots_to_create_terrains[current_slot_index_terrains]]['trade_info'].has('caption'):
								blueprint.disabled_button(true, tr('blueprints_shop.available'))
					current_slot_index_terrains += 1
				else:
					break
		# upgrades
		if slots_to_create_upgrade.size() > 0 && current_slot_index_upgrade < slots_to_create_upgrade.size():
			for i in range(1):
				if current_slot_index_upgrade < slots_to_create_upgrade.size():
					if check_construct_array('ugprades', slots_to_create_upgrade[current_slot_index_upgrade]):
						var blueprint = blueprintsNode.instantiate()
						blueprintsContainer.add_child(blueprint)
						blueprint.set_data("ugprades", slots_to_create_upgrade[current_slot_index_upgrade])
						blueprint.set_alternative_name(blueprints.content['terrains'][slots_to_create_upgrade[current_slot_index_upgrade]]['trade_info']['caption'])
						if check_construct_array('ugprades', slots_to_create_upgrade[current_slot_index_upgrade]):
							if blueprints.content['terrains'][slots_to_create_upgrade[current_slot_index_upgrade]].has('trade_info'):
								if blueprints.content['terrains'][slots_to_create_upgrade[current_slot_index_upgrade]]['trade_info'].has('caption'):
									blueprint.disabled_button(true, tr('blueprints_shop.available'))
						current_slot_index_upgrade += 1
				else:
					break
		check_items_state()

func check_items_state() -> void:
	match section:
		'all':
			# Добавить "current_slot_index_upgrade == slots_to_create_upgrade.size()" после добавления чертежей улучшений
			if current_slot_index_nodes == slots_to_create_nodes.size()\
			&& current_slot_index_terrains == slots_to_create_terrains.size():
				set_process(false)
		'nodes':
			if current_slot_index_nodes == slots_to_create_nodes.size():
				set_process(false)
		'terrains':
			if current_slot_index_terrains == slots_to_create_terrains.size():
				set_process(false)
		'upgrades':
			if current_slot_index_upgrade == slots_to_create_upgrade.size():
				set_process(false)

func open() -> void:
	opened = true
	anim.play('open')
	blur.blur(true)
	section = 'all'
	window()
	set_start_info()
	get_blueprints()
	update_nav_menu()

func close() -> void:
	opened = !true
	anim.play('close')
	blur.blur(!true)
	clear_blueprints_container()

func window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func get_data(group, index) -> void:
	if blueprints.content.has(group):
		if blueprints.content[group].has(index):
			blueprint_section = group
			blueprint_index = index
			if !blueprintsIcon.visible:
				blueprintsIcon.visible = true
			if blueprints.content[group][index].has('icon'):
				blueprintsIcon.texture = blueprints.content[group][index]['icon']
			else:
				blueprintsIcon.texture = load('res://assets/resources/ui/interactive/construct/default.png')
			if blueprints.content[group][index].has('trade_info'):
				if blueprints.content[group][index]['trade_info'].has('caption'):
					blueprintsHeader.text = blueprints.content[group][index]['trade_info']['caption']
				if blueprints.content[group][index]['trade_info'].has('description'):
					blueprintsDescription.text = blueprints.content[group][index]['trade_info']['description']
				if blueprints.content[group][index]['trade_info'].has('price'):
					if blueprints.content[group][index]['trade_info']['price'] > 0:
						blueprint_price = blueprints.content[group][index]['trade_info']['price']
						blueprintsPrice.text = tr("blueprints_shop.blueprint_cost") + ": " + "[color=#ffce5e]" + balance.format(blueprints.content[group][index]['trade_info']['price']) + ' ' + tr('money_symbol') + ' ' +  "[/color]"
					else:
						blueprintsPrice.text = ''
				else:
					blueprintsPrice.text = ''
			update_buy_button(group, index)

func check_construct_array(group,index) -> bool:
	if construct:
		match group.to_lower():
			'nodes':
				if construct.node_blueprints != []:
					if construct.node_blueprints.has(index):
						return true
			'terrains':
				if construct.terrains_blueprints != []:
					if construct.terrains_blueprints.has(index):
						return true
			'upgrades':
				if construct.upgrade_blueprints != []:
					if construct.upgrade_blueprints.has(index):
						return true
	return false

func update_buy_button(group, index) -> void:
	if !blueprintsBuy.visible:
		blueprintsBuy.visible = true
	if blueprints.content[group][index].has('trade_info'):
		if blueprints.content[group][index]['trade_info'].has('price'):
			if blueprints.content[group][index]['trade_info']['price'] > 0:
				if balance.money >= blueprints.content[group][index]['trade_info']['price']:
					blueprintsBuy.text = tr('blueprints_shop.purchase')
					blueprintsBuy.disabled = false
				else:
					blueprintsBuy.text = tr('blueprints_shop.insufficient_funds')
					blueprintsBuy.disabled = true
			else:
				blueprintsBuy.text = tr('blueprints_shop.purchase')
				blueprintsBuy.disabled = false
		else:
			blueprintsBuy.text = tr('blueprints_shop.purchase')
			blueprintsBuy.disabled = false

func get_blueprints() -> void:
	clear_blueprints_container()
	match section:
		'nodes':
			current_slot_index_nodes = 0
			slots_to_create_nodes = []
			if blueprints.content.has('nodes'):
				if blueprints.content['nodes'].keys().size() > 0:
					for i in blueprints.content['nodes']:
						slots_to_create_nodes.append(i)
		'terrains':
			current_slot_index_terrains = 0
			slots_to_create_terrains = []
			if blueprints.content.has('terrains'):
				if blueprints.content['terrains'].keys().size() > 0:
					for i in blueprints.content['terrains']:
						slots_to_create_terrains.append(i)
		'upgrades':
			current_slot_index_upgrade = 0
			current_slot_index_upgrade = []
			if blueprints.content.has('upgrades'):
				if blueprints.content['upgrades'].keys().size() > 0:
					for i in blueprints.content['upgrades']:
						current_slot_index_upgrade.append(i)
		_:
			current_slot_index_nodes = 0
			current_slot_index_terrains = 0
			current_slot_index_upgrade = 0
			slots_to_create_nodes = []
			slots_to_create_terrains = []
			slots_to_create_upgrade = []
			slots_to_create_nodes_captions = []
			slots_to_create_terrains_captions = []
			slots_to_create_upgrade_captions = []
			if blueprints.content.has('nodes'):
				if blueprints.content['nodes'].keys().size() > 0:
					for i in blueprints.content['nodes']:
						slots_to_create_nodes.append(i)
						if blueprints.content['nodes'][i].has('trade_info'):
							if blueprints.content['nodes'][i]['trade_info'].has('caption'):
								slots_to_create_nodes_captions.append(
									blueprints.content['nodes'][i]['trade_info']['caption']
								)
			if blueprints.content.has('terrains'):
				if blueprints.content['terrains'].keys().size() > 0:
					for i in blueprints.content['terrains']:
						slots_to_create_terrains.append(i)
						if blueprints.content['terrains'][i].has('trade_info'):
							if blueprints.content['terrains'][i]['trade_info'].has('caption'):
								slots_to_create_terrains_captions.append(
									blueprints.content['terrains'][i]['trade_info']['caption']
								)

			if blueprints.content.has('upgrades'):
				if blueprints.content['upgrades'].keys().size() > 0:
					for i in blueprints.content['upgrades']:
						slots_to_create_upgrade.append(i)
						if blueprints.content['upgrades'][i].has('trade_info'):
							if blueprints.content['upgrades'][i]['trade_info'].has('caption'):
								slots_to_create_upgrade_captions.append(
									blueprints.content['upgrades'][i]['trade_info']['caption']
									)
	set_process(true)

func clear_blueprints_container() -> void:
	if blueprintsContainer.get_children().size() > 0:
		for i in blueprintsContainer.get_children():
			blueprintsContainer.remove_child(i)

func update_nav_menu() -> void:
	if blueprints.content['nodes'].keys().size() > 0:
		buttonNodes.visible = true
	else:
		buttonNodes.visible = !true
	if blueprints.content['terrains'].keys().size() > 0:
		buttonTerrain.visible = true
	else:
		buttonTerrain.visible = !true
	if blueprints.content['upgrades'].keys().size() > 0:
		buttonUpgrades.visible = true
	else:
		buttonUpgrades.visible = !true

	buttonAllBlueprints.text = 'build.button.all_blueprints'
	buttonNodes.text = 'build.button.landscape_blueprints'
	buttonTerrain.text = 'build.button.buildings_blueprints'
	buttonUpgrades.text = 'build.button.upgrades_blueprints'
	match section:
		'nodes':
			buttonAllBlueprints.modulate = Color(1, 1, 1, 0.784)
			buttonNodes.modulate = Color(1, 1, 1)
			buttonTerrain.modulate = Color(1, 1, 1, 0.784)
			buttonUpgrades.modulate = Color(1, 1, 1, 0.784)
		'terrains':
			buttonAllBlueprints.modulate = Color(1, 1, 1, 0.784)
			buttonNodes.modulate = Color(1, 1, 1, 0.784)
			buttonTerrain.modulate = Color(1, 1, 1)
			buttonUpgrades.modulate = Color(1, 1, 1, 0.784)
		'upgrades':
			buttonAllBlueprints.modulate = Color(1, 1, 1, 0.784)
			buttonNodes.modulate = Color(1, 1, 1, 0.784)
			buttonTerrain.modulate = Color(1, 1, 1, 0.784)
			buttonUpgrades.modulate = Color(1, 1, 1)
		_:
			buttonAllBlueprints.modulate = Color(1, 1, 1)
			buttonNodes.modulate = Color(1, 1, 1, 0.784)
			buttonTerrain.modulate = Color(1, 1, 1, 0.784)
			buttonUpgrades.modulate = Color(1, 1, 1, 0.784)

func set_start_info() -> void:
	blueprintsHeader.text = tr('blueprints_shop.header')
	blueprintsDescription.text = tr('blueprints_shop.description')
	blueprintsPrice.text = ''
	blueprintsBuy.visible = false
	blueprintsIcon.visible = !true

func _on_close_button_pressed():
	_audio_play("click")

func _on_close_button_mouse_entered():
	_audio_play("hover")

func _on_button_all_blueprints_pressed():
	if section != 'all':
		section = 'all'
		update_nav_menu()
		get_blueprints()
		_audio_play("click")

func _on_button_all_blueprints_mouse_entered():
	if section != 'all': _audio_play("hover")

func _on_button_buildings_pressed():
	if section != 'nodes':
		section = 'nodes'
		update_nav_menu()
		get_blueprints()
		_audio_play("click")

func _on_button_buildings_mouse_entered():
	if section != 'nodes': _audio_play("hover")

func _on_button_landscape_pressed():
	if section != 'terrains':
		section = 'terrains'
		update_nav_menu()
		get_blueprints()
		_audio_play("click")

func _on_button_landscape_mouse_entered():
	if section != 'terrains':
		_audio_play("hover")

func _on_button_upgrades_pressed():
	if section != 'upgrades':
		section = 'upgrades'
		update_nav_menu()
		get_blueprints()
		_audio_play("hover")

func _on_button_upgrades_mouse_entered():
	if section != 'upgrades':
		_audio_play("hover")

func _on_button_pressed():
	if blueprintsBuy.visible:
		if !blueprintsBuy.disabled:
			_audio_play("click")
			_audio_play("trade")
			construct.add_blueprint(blueprint_index, blueprint_section)
			balance.remove_money(blueprint_price)
			get_blueprints()
			set_start_info()

func _on_button_mouse_entered():
	if blueprintsBuy.visible:
		if !blueprintsBuy.disabled:
			_audio_play("hover")

func _audio_play(_ogg:String) -> void:
	var audio = AudioStreamPlayer.new()
	self.add_child(audio)
	audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
	audio.stream = load('res://assets/sounds/ui/'+_ogg+'.ogg')
	audio.play()

func _on_audio_finished(audio) -> void:
	audio.queue_free()