extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var data:Node2D = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")

@onready var node:PackedScene = load("res://assets/nodes/ui/interactive/construct/blueprint.tscn")
@onready var scroll_container_info:ScrollContainer = $Main/MainContent/InfoContent/ScrollContainer
@onready var container:GridContainer = $Main/MainContent/BlueprintsContent/ScrollContainer/GridContainer

@onready var icon:TextureRect = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/IconContainer/TextureRect
@onready var caption:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/HeaderContainer/Header
@onready var description:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/DescriptionContainer/Description
@onready var resources:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ResourcesContainer/Resources
@onready var time_create:Label = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/TimeContainer/Time
@onready var button:Button = $Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ButtonContainer/Button

@onready var navmenu:HBoxContainer = $Main/ScrollContainer/NavMenu
@onready var navmenu_button_landscapes:Button = $Main/ScrollContainer/NavMenu/ButtonLandscape
@onready var navmenu_button_nodes:Button = $Main/ScrollContainer/NavMenu/ButtonBuildings
@onready var navmenu_button_upgrades:Button = $Main/ScrollContainer/NavMenu/ButtonUpgrades

@onready var navmenu_button_all:Button = $Main/ScrollContainer/NavMenu/ButtonAllBlueprints

@onready var button_script = get_node("/root/"+main+"/UI/Interactive/ConstructMenu/Main/MainContent/InfoContent/ScrollContainer/VBoxContainer/ButtonContainer/Button")
@onready var anim:AnimationPlayer = $AnimationPlayer

var construct_menu_header:String = tr("Меню строительства")
var construct_menu_description:String = tr("Нет чертежей. Чтобы получить новые чертежи — проходите квесты или приобретайте у специальный торговцев.")
var construct_menu_description_empty:String = tr("Выбор чертежей происходит в левом окне. \n\nВерхние вкладки служат для группировки чертежей по их типам.")

var construct_menu_selected_nodes_header:String = tr("Постройки")
var construct_menu_selected_landscapes_header:String = tr("Ландшафт")
var construct_menu_selected_upgrades_header:String = tr("Улучшения")

var construct_menu_selected_nodes:String = tr("Чертежи данного типа дают возможность возводить фермерские постройки и декорации для фермы.")
var construct_menu_selected_landscapes:String = tr("Эти чертежи позволяют преобразовывать ландшафт фермы.")
var construct_menu_selected_upgrades:String = tr("Чертежи этого типа используются для модернизации конкретных зданий. После улучшения здания становятся доступны новые функции или контент, связанные с ними.")


var index:int
var section:String = "all"
var opened:bool = false
var all_items:bool
var terrains_blueprints:Array[int] = [1,2,3,4,5,6,7,8,9,10]
var node_blueprints:Array[int] = [1,2,3,4,5,6,7,8,9,10]
var upgrade_blueprints:Array[int] = []

var items:Object = Items.new()
var blueprints:Object = Blueprints.new()
var slots_to_create_terrains = []
var slots_to_create_nodes = []
var slots_to_create_upgrade = []
var current_slot_index_terrains = 0
var current_slot_index_nodes = 0
var current_slot_index_upgrade = 0

func _ready():
	check_window()

func _input(_event):
	if Input.is_action_just_pressed("esc")\
	&& blur.state\
	&& opened:
		close()

func _process(_delta) -> void:
	if visible:
		# nodes
		if slots_to_create_nodes.size() > 0 && current_slot_index_nodes < slots_to_create_nodes.size():
			for i in range(1):
				if current_slot_index_nodes < slots_to_create_nodes.size():
					var blueprint = node.instantiate()
					container.add_child(blueprint)
					blueprint.set_data("nodes", slots_to_create_nodes[current_slot_index_nodes])
					current_slot_index_nodes += 1
				else:
					break
		# terrains
		if slots_to_create_terrains.size() > 0 && current_slot_index_terrains < slots_to_create_terrains.size():
			for i in range(1):
				if current_slot_index_terrains < slots_to_create_terrains.size():
					var blueprint = node.instantiate()
					container.add_child(blueprint)
					blueprint.set_data("terrains", slots_to_create_terrains[current_slot_index_terrains])
					current_slot_index_terrains += 1
				else:
					break
		# upgrades
		if slots_to_create_upgrade.size() > 0 && current_slot_index_upgrade < slots_to_create_upgrade.size():
			for i in range(1):
				if current_slot_index_upgrade < slots_to_create_upgrade.size():
					var blueprint = node.instantiate()
					container.add_child(blueprint)
					blueprint.set_data("ugprades", slots_to_create_upgrade[current_slot_index_upgrade])
					current_slot_index_upgrade += 1
				else:
					break

func get_data(group:String, id:int) -> void:
	if blueprints.content.has(group):
		if blueprints.content[group].has(id):
			if blueprints.content[group][id].has("config"):
				index = id
				section = group
				reset_data()
				if blueprints.content[group][id].has("icon"):
					if blueprints.content[group][id]["icon"] is CompressedTexture2D:
						icon.texture = blueprints.content[group][id]["icon"]
						icon.visible = true
					else:
						icon.visible = false
				else:
					icon.visible = false

				if blueprints.content[group][id].has("caption"):
					if blueprints.content[group][id]["caption"] is String:
						caption.text = blueprints.content[group][id]["caption"]
						caption.visible = true
					else:
						caption.visible = false
				else:
					caption.visible = false

				if blueprints.content[group][id].has("description"):
					if blueprints.content[group][id]["description"] is String:
						description.text = blueprints.content[group][id]["description"]
						description.visible = true
					else:
						description.visible = false
				else:
					description.visible = false
				
				match group:
					"nodes":
						if blueprints.content[group][id]["config"].has("node"):
							button.visible = true
							update_button_state()		
							if blueprints.content[group][id]["config"].has("resources"):
								get_all_required_items(group, id)
								resources.visible = true
								check_all_required_items(group, id)
								if all_items:
									button.disabled = false
									button.id = id
									button.group = group
								else:
									button.disabled = true
					"terrains":
						if blueprints.content[group][id]["config"].has("terrain"):
							button.visible = true
							button.disabled = false
							button.id = id
							button.group = group
			else:
				return
		else:
			return
	else:
		return

func update_button_state() -> void:
	match section:
		"terrains":
			navmenu_button_landscapes.modulate = Color(1, 1, 1)
			navmenu_button_nodes.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_upgrades.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_all.modulate = Color(1, 1, 1, 0.784)
		"nodes":
			navmenu_button_landscapes.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_nodes.modulate = Color(1, 1, 1)
			navmenu_button_upgrades.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_all.modulate = Color(1, 1, 1, 0.784)
		"all":
			navmenu_button_landscapes.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_nodes.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_upgrades.modulate = Color(1, 1, 1, 0.784)
			navmenu_button_all.modulate = Color(1, 1, 1)

func get_all_required_items(group:String, id:int) -> void:
	if blueprints.content[group][id]["config"]["resources"] != {}:
		for i in blueprints.content[group][id]["config"]["resources"]:
			var resource_name = items.content[i]["caption"]
			var required_amount = blueprints.content[group][id]["config"]["resources"][i]["amount"]
			var available_amount = inventory.get_item_amount(i)
			resources.text += "• " + str(resource_name) + " (" + str(available_amount) + "/" + str(required_amount) + ")"

func check_all_required_items(group:String, id:int) -> void:
	all_items = true
	for resource in blueprints.content[group][id]["config"]["resources"]:
		var required_amount = blueprints.content[group][id]["config"]["resources"][resource]["amount"]
		var available_amount = inventory.get_item_amount(resource)
		if available_amount < required_amount:
			all_items = false
			break

func create_all_blueprints() -> void:
	match section:
		"terrains":
			if terrains_blueprints != []:
				for i in terrains_blueprints:
					if blueprints.content.has("terrains"):
						if blueprints.content["terrains"].has(i):
							slots_to_create_terrains.append(i)
						else:
							pass
					else:
						pass

		"nodes":
			if node_blueprints != []:
				for i in node_blueprints:
					if blueprints.content.has("nodes"):
						if blueprints.content["nodes"].has(i):
							slots_to_create_nodes.append(i)
						else:
							pass
					else:
						pass

		"all": 
			slots_to_create_terrains = []
			slots_to_create_nodes = []
			slots_to_create_upgrade = []
			current_slot_index_terrains = 0
			current_slot_index_nodes = 0
			current_slot_index_upgrade = 0
			if terrains_blueprints != []:
				for i in terrains_blueprints:
					if blueprints.content['terrains'].has(i):
						slots_to_create_terrains.append(i)
			if node_blueprints != []:
				for i in node_blueprints:
					if blueprints.content['nodes'].has(i):
						slots_to_create_nodes.append(i)
			if upgrade_blueprints != []:
				for i in upgrade_blueprints:
					if blueprints.content['nodes'].has(i):
						slots_to_create_upgrade.append(i)

func remove_all_blueprints() -> void:
	for i in container.get_children():
		container.remove_child(i)

func open() -> void:
	anim.play("open")
	blur.blur(true)
	opened = true
	section = "all"

	set_start_info()
	update_navmenu()
	update_button_state()
	remove_all_blueprints()
	create_all_blueprints()

func close() -> void:
	anim.play("close")
	blur.blur(false)
	opened = false

func update_navmenu() -> void:
	navmenu_button_all.visible = true
	navmenu_button_all.text = tr("Все чертежи")
	if terrains_blueprints != []:
		navmenu_button_landscapes.visible = true
		navmenu_button_landscapes.text = tr("Чертежи ландшафта")
	else:
		navmenu_button_landscapes.visible = false

	if node_blueprints != []:
		navmenu_button_nodes.visible = true
		navmenu_button_nodes.text = tr("Чертежи построек")
	else:
		navmenu_button_nodes.visible = false

	if upgrade_blueprints != []:
		navmenu_button_upgrades.visible = true
		navmenu_button_upgrades.text = tr("Чертежи улучшений")
	else:
		navmenu_button_upgrades.visible = false

func set_start_info() -> void:
	caption.text = construct_menu_header
	if terrains_blueprints == []\
	&& node_blueprints == []\
	&& upgrade_blueprints == []:
		description.text = construct_menu_description
	else:
		description.text = construct_menu_description_empty

	caption.visible = true
	description.visible = true
	icon.visible = false
	resources.visible = false
	time_create.visible = false
	button.visible = false
	resources.text = ""
	time_create.text = ""
	
func reset_data() -> void:
	caption.visible = false
	description.visible = false
	icon.visible = false
	resources.visible = false
	time_create.visible = false
	button.visible = false
	caption.text = ""
	description.text = ""
	resources.text = ""
	time_create.text = ""

func get_blueprints() -> Dictionary:
	return {
		"terrains_blueprints": terrains_blueprints,
		"node_blueprints": node_blueprints,
		"upgrade_blueprints": upgrade_blueprints,
	}

func load_blueprints(terrains:Array[int], nodes:Array[int], upgrades:Array[int]) -> void:
	terrains_blueprints = terrains
	node_blueprints = nodes
	upgrade_blueprints = upgrades

func clear_blueprints() -> void:
	terrains_blueprints.clear()
	node_blueprints.clear()
	upgrade_blueprints.clear()

func check_window() -> void:
	visible = opened
	if pause:
		pause.other_menu = opened

func _on_close_pressed() -> void:
	close()

# navmenu
func _on_button_landscape_pressed():
	section = "terrains"
	caption.text = construct_menu_selected_landscapes_header
	if terrains_blueprints == []\
	&& node_blueprints == []\
	&& upgrade_blueprints == []:
		description.text = ""
	else:
		description.text = construct_menu_selected_landscapes

	caption.visible = true
	description.visible = true
	icon.visible = false
	resources.visible = false
	time_create.visible = false
	button.visible = false
	update_button_state()
	remove_all_blueprints()
	create_all_blueprints()

func _on_button_buildings_pressed():
	section = "nodes"
	caption.text = construct_menu_selected_nodes_header
	if terrains_blueprints == []\
	&& node_blueprints == []\
	&& upgrade_blueprints == []:
		description.text = ""
	else:
		description.text = construct_menu_selected_nodes

	caption.visible = true
	description.visible = true
	icon.visible = false
	resources.visible = false
	time_create.visible = false
	button.visible = false
	update_button_state()
	remove_all_blueprints()
	create_all_blueprints()

func _on_button_upgrades_pressed():
	section = "upgrades"
	caption.text = construct_menu_selected_upgrades_header
	if terrains_blueprints == []\
	&& node_blueprints == []\
	&& upgrade_blueprints == []:
		description.text = ""
	else:
		description.text = construct_menu_selected_upgrades

	caption.visible = true
	description.visible = true
	icon.visible = false
	resources.visible = false
	time_create.visible = false
	button.visible = false
	update_button_state()
	remove_all_blueprints()
	create_all_blueprints()


func _on_button_all_blueprints_pressed():
	section = "all"
	set_start_info()
	update_navmenu()
	update_button_state()
	remove_all_blueprints()
	create_all_blueprints()