extends TileMap

@onready var main = str(get_tree().root.get_child(1).name)
@onready var data = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

var SEASON_ATLAS = {
	"spring": {
		"ground": load("res://assets/resources/world/landscape/spring/ground.png"),
		"roads": load("res://assets/resources/world/landscape/spring/roads.png"),
		"farmlands": load(""),
		"waterings": load(""),
		"coasts": load(""),
		"water": load(""),
	},
	"summer": {
		"ground": load("res://assets/resources/world/landscape/summer/ground.png"),
		"roads": load("res://assets/resources/world/landscape/summer/roads.png"),
		"farmlands": load("res://assets/resources/world/landscape/summer/farmlands.png"),
		"waterings": load("res://assets/resources/world/landscape/summer/waterings.png"),
		"coasts": load("res://assets/resources/world/landscape/summer/coasts.png"),
		"water": load("res://assets/resources/world/landscape/summer/water.png"),
	},
	"autumn": {
		"ground": load("res://assets/resources/world/landscape/autumn/ground.png"),
		"roads": load("res://assets/resources/world/landscape/autumn/roads.png"),
		"farmlands": load(""),
		"waterings": load(""),
		"coasts": load(""),
		"water": load(""),
	},
	"winter": {
		"ground": load("res://assets/resources/world/landscape/winter/ground.png"),
		"roads": load("res://assets/resources/world/landscape/winter/roads.png"),
		"farmlands": load(""),
		"waterings": load(""),
		"coasts": load(""),
		"water": load(""),
	},
}

func _ready():
	if clock:
		update_atlas(
			clock.seasons[clock.season]
		)

func _process(_delta):
	if !blur.state:
		if has_node("/root/"+main+"/ConstructionManager"):
			if has_node("/root/"+main+"/ConstructionManager/Grid"):
				if grid.mode != grid.modes.NOTHING:
					grid_movement()

func grid_movement() -> void:
	var movement:Vector2 = local_to_map(get_global_mouse_position())
	grid.set_position(map_to_local(movement))

func update_atlas(season:String) -> void:
	if SEASON_ATLAS.has(season):
		tile_set.get_source(0).texture = SEASON_ATLAS[season]["ground"]
		tile_set.get_source(1).texture = SEASON_ATLAS[season]["roads"]
		#if SEASON_ATLAS[season].has("ground")\
		#&& SEASON_ATLAS[season].has("roads")\
		#&& SEASON_ATLAS[season].has("farmlands")\
		#&& SEASON_ATLAS[season].has("waterings")\
		#&& SEASON_ATLAS[season].has("coasts")\
		#&& SEASON_ATLAS[season].has("water"):
		#	tile_set.get_source(0).texture = SEASON_ATLAS[season]["ground"]
		#	tile_set.get_source(1).texture = SEASON_ATLAS[season]["roads"]
		#	tile_set.get_source(2).texture = SEASON_ATLAS[season]["farmlands"]
		#	tile_set.get_source(3).texture = SEASON_ATLAS[season]["waterings"]
		#	tile_set.get_source(4).texture = SEASON_ATLAS[season]["coasts"]
		#	tile_set.get_source(5).texture = SEASON_ATLAS[season]["water"]
		for node in buildings.get_children():
			if node.has_method("get_data"):
				if node.object.has(node.level):
					if node.object[node.level].has("seasons"):
						if node.object[node.level]["seasons"].has(season):
							if node.object[node.level]["seasons"][season].has("default")\
							&& node.object[node.level]["seasons"][season].has("hovered"):
								node.update()
			else:
				if node.has_method("update"):
					if node.object.has("seasons"):
						if node.object["seasons"].has(season):
							if node.object["seasons"][season].has("default")\
							&& node.object["seasons"][season].has("hovered"):
								node.update()

		if nature.get_children() != []:
			nature.clear_all_arrays()
			nature.new_texture()
			for node in nature.get_children(): 
				if data.remove_suffix(node.name) == "tree":
					node.change_texture(nature.trees[node.index])
				if data.remove_suffix(node.name) == "stone":
					node.change_texture(nature.stones[node.index])
				if data.remove_suffix(node.name) == "weed":
					node.change_texture(nature.weeds[node.index])

