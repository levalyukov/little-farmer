extends Button

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")
@onready var hud:Control = get_node("/root/"+main+"/UI/HUD/GameHud")
@onready var inventory:Control = get_node("/root/"+main+"/UI/Interactive/Inventory")
@onready var craft:Control = get_node("/root/"+main+"/UI/Interactive/ConstructMenu")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

var items:Object = Items.new()
var blueprints:Object = Blueprints.new()
var materials:Object = BuildingMaterials.new()

var disable:bool
var group:String
var id:int

func _on_pressed():
	if visible:
		building_process()

func building_process() -> void:
	if blueprints.content.has(group):
		if blueprints.content[group].has(id):
			if blueprints.content[group][id]["config"].has("node"):
				grid.node_id = id
				grid.building_group = group
				grid.node_source = blueprints.content[group][id]["config"]["node"]
				grid.node_shadow = blueprints.content[group][id]["config"]["shadow"]
				grid.grid_dimensions = blueprints.content[group][id]["config"]["area"]
				grid.mode = grid.modes.BUILD
				grid.visible = true
				grid.generate_grid()
				craft.close()
				hud.state(true, "all")
			else:
				data.debug("The key element is missing - 'node'", "error")
				reset_grid_data()
				return
		else:
			data.debug("Invalid blueprint ID: " + str(id), "error")
			return
	else:
		data.debug("Invalid blueprint group: " + str(group), "error")
		return

func reset_grid_data() -> void:
	grid.building_node = null
	grid.mode = grid.modes.NOTHING
	grid.visible = false
