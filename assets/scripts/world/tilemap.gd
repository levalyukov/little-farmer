extends TileMap

@onready var main = str(get_tree().root.get_child(2).name)
@onready var data = get_node("/root/"+main)
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var farming:Node2D = get_node("/root/"+main+"/FarmingManager")
@onready var buildings:Node = get_node("/root/"+main+"/ConstructionManager")
@onready var nature:Node2D = get_node("/root/"+main+"/Nature")
@onready var canvas:CanvasGroup = get_node("/root/"+main+"/ShadowManager/CanvasGroup")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")

var SEASON_ATLAS = {
	"spring": {
		"ground": load("res://assets/resources/world/landscape/spring/ground.png"),
		"roads": load("res://assets/resources/world/landscape/spring/roads.png"),
		"farmlands": load("res://assets/resources/world/landscape/spring/farmlands.png"),
		"waterings": load("res://assets/resources/world/landscape/spring/waterings.png"),
		"coasts": load("res://assets/resources/world/landscape/spring/coasts.png"),
		"water": load("res://assets/resources/world/landscape/spring/water.png"),
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
		"farmlands": load("res://assets/resources/world/landscape/autumn/farmlands.png"),
		"waterings": load("res://assets/resources/world/landscape/autumn/waterings.png"),
		"coasts": load("res://assets/resources/world/landscape/autumn/coasts.png"),
		"water": load("res://assets/resources/world/landscape/autumn/water.png"),
	},
	"winter": {
		"ground": load("res://assets/resources/world/landscape/winter/ground.png"),
		"roads": load("res://assets/resources/world/landscape/winter/roads.png"),
		"farmlands": load("res://assets/resources/world/landscape/winter/farmlands.png"),
		"waterings": load("res://assets/resources/world/landscape/winter/waterings.png"),
		"coasts": load("res://assets/resources/world/landscape/winter/coasts.png"),
		"water": load("res://assets/resources/world/landscape/winter/water.png"),
	},
}

func _process(_delta):
	if !blur.state:
		if has_node("/root/"+main+"/ConstructionManager"):
			if has_node("/root/"+main+"/ConstructionManager/Grid"):
				if grid.mode != grid.modes.NOTHING:
					grid_movement()

func grid_movement() -> void:
	var movement:Vector2 = local_to_map(get_global_mouse_position())
	grid.set_position(map_to_local(movement))

func set_atlas(season:String) -> void:
	if SEASON_ATLAS.has(season):
		if SEASON_ATLAS[season].has("ground")\
		&& SEASON_ATLAS[season].has("roads")\
		&& SEASON_ATLAS[season].has("farmlands")\
		&& SEASON_ATLAS[season].has("waterings")\
		&& SEASON_ATLAS[season].has("coasts")\
		&& SEASON_ATLAS[season].has("water"):
			if SEASON_ATLAS[season]["ground"] is CompressedTexture2D\
			&& SEASON_ATLAS[season]["roads"] is CompressedTexture2D\
			&& SEASON_ATLAS[season]["farmlands"] is CompressedTexture2D\
			&& SEASON_ATLAS[season]["waterings"] is CompressedTexture2D\
			&& SEASON_ATLAS[season]["coasts"] is CompressedTexture2D\
			&& SEASON_ATLAS[season]["water"] is CompressedTexture2D:
				tile_set.get_source(0).texture = SEASON_ATLAS[season]["ground"]
				tile_set.get_source(1).texture = SEASON_ATLAS[season]["roads"]
				tile_set.get_source(2).texture = SEASON_ATLAS[season]["farmlands"]
				tile_set.get_source(3).texture = SEASON_ATLAS[season]["waterings"]
				tile_set.get_source(4).texture = SEASON_ATLAS[season]["coasts"]
				tile_set.get_source(5).texture = SEASON_ATLAS[season]["water"]
				if buildings:
					if buildings.get_children() != []:
						for node in buildings.get_children():
							if node:
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
								else:
									if node.has_method("update"):
										if node.object.has("seasons"):
											if node.object["seasons"].has(season):
												if node.object["seasons"][season].has("default")\
												&& node.object["seasons"][season].has("hovered"):
													node.update()

				if nature:
					if nature.get_children() != []:
						nature.clear_all_arrays()
						nature.new_texture()
						for node in nature.get_children(): 
							if node:
								if node.has_method('change_texture'):
									if data.remove_suffix(node.name) == "tree":
										node.change_texture(nature.trees[node.index])
									if data.remove_suffix(node.name) == "stone":
										node.change_texture(nature.stones[node.index])
									if data.remove_suffix(node.name) == "weed":
										node.change_texture(nature.weeds[node.index])

				if canvas:
					if canvas.get_children() != []:
						for i in canvas.get_children():
							if i:
								if i.has_method("is_nature_shadow"):
									if i.type == "tree":
										i.change_sprite(nature.trees_shadow[i.index])
									if i.type == "stone":
										i.change_sprite(nature.stones_shadow[i.index])
									if i.type == "weed":
										i.change_sprite(nature.weeds_shadow[i.index])

				if farming:
					if farming.get_children() != []:
						for i in farming.get_children():
							if i:
								if i.has_method("check_plant_season"):
									i.check_plant_season()
