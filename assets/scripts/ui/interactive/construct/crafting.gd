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
var id:int

func _on_pressed():
	if visible:
		build(id)

func build(index:int) -> void:
	start_building(index)

func start_building(index) -> void:
	var target_array = blueprints.content[index]["type"].keys() 
	match target_array[0]:
		"terrain":
			if blueprints.content[index]["type"]["terrain"].has("terrain_set"):
				grid.terrain_set = blueprints.content[index]["type"]["terrain"]["terrain_set"]
				grid.mode = grid.modes.TERRAIN_SET
				grid.visible = true
				craft.close()
				hud.state(true, "all")
			else:
				data.debug("The key element is missing - 'terrain_set'", "error")
				reset_grid_data(target_array[0])

		"node":
			if blueprints.content[index]["type"]["node"].has("source"):
				if blueprints.content[index]["type"]["node"].has("shadow"):
					grid.building_id = index
					grid.building_node = blueprints.content[index]["type"]["node"]["source"]
					grid.building_shadow = blueprints.content[index]["type"]["node"]["shadow"]
					grid.mode = grid.modes.BUILD
					grid.visible = true
					craft.close()
					hud.state(true, "all")
				else:
					data.debug("The key element is missing - 'shadow'", "error")
					reset_grid_data(target_array[0])
			else:
				data.debug("The key element is missing - 'source'", "error")
				reset_grid_data(target_array[0])		

		_:
			data.debug("Invalid type - "+str(target_array[0]), "error")
			reset_grid_data(target_array[0])


func reset_grid_data(index) -> void:
	match index:
		"terrain":
			grid.terrain_set = 0
			grid.mode = grid.modes.NOTHING
			grid.visible = false
		"node":
			grid.building_node = null
			grid.mode = grid.modes.NOTHING
			grid.visible = false
		_:
			pass
