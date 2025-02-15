extends Node2D

@onready var main:String = GameData.main
@onready var data = get_node("/root/"+main)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var collision:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid/GridParent")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@onready var sprite:Sprite2D = $Sprite2D
@onready var timer:Timer = $Timer
@onready var check_water_timer:Timer = $CheckWaterTimer

var crops:Object = Crops.new()
var plantID:int
var condition:int = phases.PLANTED
var fertilizer:int = fertilizers.NOTHING
var degree:int

enum phases {PLANTED,GROWING,GROWED,DEAD}
enum fertilizers {NOTHING, COMPOST, HUMUS, MANURE}

func _process(_delta):
	if pause.paused:
		timer.set_paused(true)
	else:
		timer.set_paused(false)

func plant(id:int) -> void:
	plantID = id
	sprite.rect(id)
	check_water_timer.wait_time = crops.crops["check_watering"]
	check_water_timer.start()
	
func set_fertilizer(type:int) -> void:
	match type:
		0:
			fertilizer = fertilizers.NOTHING
		1:
			fertilizer = fertilizers.COMPOST
		2:
			fertilizer = fertilizers.HUMUS
		3:
			fertilizer = fertilizers.MANURE
			
func check(vector:Vector2i) -> void:
	if !pause.paused:
		if collision.check_cell(vector, collision.farmland_layer)\
		&& !collision.check_cell(vector, collision.watering_layer)\
		&& condition != phases.DEAD:
			condition = phases.PLANTED
			if degree < crops.crops[plantID]["mortality"]:
				degree += 1
			else:
				condition = phases.DEAD

		elif collision.check_cell(vector, collision.farmland_layer)\
		&& collision.check_cell(vector, collision.watering_layer)\
		&& condition != phases.DEAD:
			condition = phases.GROWING
			set_fertilizer(randi_range(0,3))
			growth()
			check_water_timer.stop()

func growth() -> void:
	if condition == phases.GROWING:
		match fertilizer:
			fertilizers.NOTHING:
				timer.wait_time = randf_range(
					crops.crops[plantID]["growth_rate"] * 0.849,
					crops.crops[plantID]["growth_rate"]
				)
			fertilizers.COMPOST:
				timer.wait_time = randf_range(
					crops.crops[plantID]["growth_rate"] * 0.621,
					crops.crops[plantID]["growth_rate"] * 0.995
				)
			fertilizers.HUMUS:
				timer.wait_time = randf_range(
					crops.crops[plantID]["growth_rate"] * 0.431,
					crops.crops[plantID]["growth_rate"] * 0.894
				)
			fertilizers.MANURE:
				timer.wait_time = randf_range(
					crops.crops[plantID]["growth_rate"] * 0.332,
					crops.crops[plantID]["growth_rate"] * 0.792
				)
		timer.start()
	if condition == phases.GROWED:
		timer.stop()

func get_data() -> Dictionary:
	return {
		"plantID": plantID,
		"degree": degree,
		"condition": condition,
		"fertilizer": fertilizer,
		"region_rect.x": sprite.region_rect.position.x,
		"region_rect.y": sprite.region_rect.position.y,
		"growth_level": sprite.level,
		"position": tilemap.local_to_map(global_position),
	}

func set_data(
	id:int, 
	conditionID:int, 
	degreeID:int, 
	fertilizerID:int, 
	region_rect_x:int, 
	region_rect_y:int, 
	level:int, 
	vector:Vector2i,
	indexZ:int,
	caption:String,
	) -> void:
	plantID = id
	condition = conditionID
	degree = degreeID
	fertilizer = fertilizerID
	sprite.region_rect.position.x = region_rect_x
	sprite.region_rect.position.y = region_rect_y
	sprite.level = level
	self.z_index = indexZ
	self.name = caption
	set_position(tilemap.map_to_local(vector))
	growth()
	check(vector)

func get_condition(condition_type:int) -> String:
	match condition_type:
		0:
			return tr("Посажено")
		1:
			return tr("Процветает")
		2:
			return tr("Выросло")
		3:
			return tr("Погибло")
		_:
			return ""

func check_plant_season() -> void:
	for i in crops.crops[plantID]["season"]:
		if i != clock.get_season():
				condition = phases.DEAD
				sprite.set_rect(0, 160)

func _on_collision_mouse_entered() -> void:
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if crops.crops.has(plantID):
			if crops.crops[plantID].has("caption"):
				if typeof(crops.crops[plantID]["caption"]) == TYPE_STRING:
					var plant_status = tr("Состояние")
					if fertilizer != fertilizers.NOTHING:
						var fertilized_plant = tr("Удобрено")
						tip.tooltip(
							crops.crops[plantID]["caption"] +"\n"+
							str(plant_status) + ": " + str(get_condition(condition)) +"\n"+
							str(fertilized_plant)
						)
					else:
						tip.tooltip(
							crops.crops[plantID]["caption"] +"\n"+
							str(plant_status) + ": " + str(get_condition(condition))
						)
				else:
					data.debug("The 'caption' element is not a string type. Variant.type: " + str(typeof(crops.crops[plantID]["caption"])), "error")
			else:
				data.debug("The 'caption' element is missing.", "error")
		else:
			data.debug("Invalid ID: " + str(plantID), "error")
		
func _on_collision_mouse_exited() -> void:
	if !blur.state:
		tip.tooltip()

func _on_check_water_timer_timeout():
	check(tilemap.local_to_map(position))