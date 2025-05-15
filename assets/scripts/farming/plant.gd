extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
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
@onready var indicator:Sprite2D = $Indicator
@onready var anim:AnimationPlayer = $AnimationPlayer

var items:Object = Items.new()
var crops:Object = Crops.new()

var plantID:int
var condition:int = phases.planted
var fertilizer:int = fertilizers.nothing
var degree:int
var loaded:bool = false

var is_active:bool = false

enum phases {planted, growing, requiresWatering, growed, dead}
enum fertilizers {nothing, regularCompost, highQualityCompost}

func plant(id:int) -> void:
	plantID = id
	sprite.rect(id)
	check_water_timer.wait_time = crops.crops["check_watering"]
	check_water_timer.start()
			
func check(vector:Vector2i) -> void:
	if !pause.paused:
		if collision.check_cell(vector, collision.farmland_layer)\
		&& !collision.check_cell(vector, collision.watering_layer)\
		&& condition != phases.dead:
			condition = phases.planted
			if degree < crops.crops[plantID]["mortality"]:
				degree += 1
			else:
				condition = phases.dead

		elif collision.check_cell(vector, collision.farmland_layer)\
		&& collision.check_cell(vector, collision.watering_layer)\
		&& condition != phases.dead:
			condition = phases.growing
			check_water_timer.stop()
			if collision.check_fertilizer(vector):
				match collision.get_fertilizer(vector):
					61:
						fertilizer = fertilizers.regularCompost
						timer.wait_time = crops.crops[plantID]["growth_rate"] - (items.content[61]["func"]["reducing"] / 100.0) * crops.crops[plantID]["growth_rate"]
					62:
						fertilizer = fertilizers.highQualityCompost
						timer.wait_time = crops.crops[plantID]["growth_rate"] - (items.content[62]["func"]["reducing"] / 100.0) * crops.crops[plantID]["growth_rate"]
			else:
				timer.wait_time = crops.crops[plantID]["growth_rate"]
			growth()

func check_water(vector:Vector2i) -> void:
	if collision.check_cell(vector, collision.farmland_layer)\
	&& collision.check_cell(vector, collision.watering_layer)\
	&& condition != phases.dead:
		tilemap.set_cells_terrain_connect(collision.watering_layer,[vector],0,-1)
		condition = phases.requiresWatering
		degree = 0
		timer.stop()
		check_water_timer.start()

func requires_watering(vector:Vector2i) -> void:
	if !pause.paused:
		if collision.check_cell(vector, collision.farmland_layer)\
		&& !collision.check_cell(vector, collision.watering_layer)\
		&& condition == phases.requiresWatering\
		&& condition != phases.dead:
			if !indicator.visible:
				indicator.visible = true
				if !anim.is_playing(): 
					anim.play('bubble')
			if degree < crops.crops[plantID]["mortality"]:
				degree += 1
			else:
				condition = phases.dead
				check_water_timer.stop()
				if indicator.visible:
					indicator.visible = !true
					if anim.is_playing():
						anim.stop()
		elif collision.check_cell(vector, collision.farmland_layer)\
		&& collision.check_cell(vector, collision.watering_layer)\
		&& condition == phases.requiresWatering\
		&& condition != phases.dead:
			degree = 0
			condition = phases.growing
			check_water_timer.stop()
			if collision.check_fertilizer(vector):
				match collision.get_fertilizer(vector):
					61:
						fertilizer = fertilizers.regularCompost
						timer.wait_time = crops.crops[plantID]["growth_rate"] - (items.content[61]["func"]["reducing"] / 100.0) * crops.crops[plantID]["growth_rate"]
					62:
						fertilizer = fertilizers.highQualityCompost
						timer.wait_time = crops.crops[plantID]["growth_rate"] - (items.content[62]["func"]["reducing"] / 100.0) * crops.crops[plantID]["growth_rate"]
			else:
				timer.wait_time = crops.crops[plantID]["growth_rate"]
			growth()
			if indicator.visible:
				indicator.visible = !true
				if anim.is_playing():
					anim.stop()

func growth() -> void:
	if loaded:
		loaded = false
	if condition == phases.growing:
		timer.start()
	if condition == phases.growed:
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
		"time_left": timer.get_time_left()
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
		time_lefted:float
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
	if time_lefted <= 0.0:
		if fertilizerID != 0:
			match fertilizerID:
				1:
					fertilizer = fertilizers.regularCompost
					time_lefted = crops.crops[plantID]["growth_rate"] - (items.content[61]["func"]["reducing"] / 100.0) * crops.crops[plantID]["growth_rate"]
				2:
					fertilizer = fertilizers.highQualityCompost
					time_lefted = crops.crops[plantID]["growth_rate"] - (items.content[62]["func"]["reducing"] / 100.0) * crops.crops[plantID]["growth_rate"]
		else:
			time_lefted = crops.crops[plantID]["growth_rate"]
	else:
		if fertilizerID != 0:
			match fertilizerID:
				1:
					fertilizer = fertilizers.regularCompost
				2:
					fertilizer = fertilizers.highQualityCompost
	timer.set_wait_time(time_lefted)
	loaded = true
	check_water_timer.start()

func get_condition(condition_type:int) -> String:
	match condition_type:
		0:
			return tr("plant_condition.planted")
		1:
			return tr("plant_condition.growing")
		2:
			return tr("plant_condition.requires_watering")
		3:
			return tr("plant_condition.growed")
		4:
			return tr("plant_condition.dead")
		_:
			return ""

func check_plant_season() -> void:
	for i in crops.crops[plantID]["season"]:
		if i != clock.get_season():
			condition = phases.dead
			sprite.set_rect(0, 160)

func _on_collision_mouse_entered() -> void:
	if !blur.state\
	&& grid.mode == grid.modes.NOTHING:
		if crops.crops.has(plantID):
			if crops.crops[plantID].has("caption"):
				if crops.crops[plantID]["caption"] is String:
					if fertilizer != fertilizers.nothing:
						if !tip.visible:
							tip.tooltip(
								tr(crops.crops[plantID]["caption"]) +"\n"+
								tr("tooltip.plant_condition") + ": " + str(get_condition(condition)) +"\n"+
								tr('tooltip.plant_fertilized')
							)
					else:
						if !tip.visible:
							tip.tooltip(
								tr(crops.crops[plantID]["caption"]) +"\n"+
								tr("tooltip.plant_condition") + ": " + str(get_condition(condition))
							)
		
func _on_collision_mouse_exited() -> void:
	if !blur.state:
		if tip.visible:
			tip.tooltip()

func _on_check_water_timer_timeout():
	if condition != phases.requiresWatering:
		if !loaded:
			check(tilemap.local_to_map(position))
		else:
			if collision.check_cell(tilemap.local_to_map(position), collision.farmland_layer)\
			&& !collision.check_cell(tilemap.local_to_map(position), collision.watering_layer)\
			&& condition != phases.dead:
				condition = phases.planted
				if degree < crops.crops[plantID]["mortality"]:
					degree += 1
				else:
					condition = phases.dead
			elif collision.check_cell(tilemap.local_to_map(position), collision.farmland_layer)\
			&& collision.check_cell(tilemap.local_to_map(position), collision.watering_layer)\
			&& condition != phases.dead:
				condition = phases.growing
				check_water_timer.stop()
				growth()
	else:
		requires_watering(tilemap.local_to_map(self.global_position))

func increase_growth() -> void:
	if !pause.paused:
		if crops.crops.has(plantID):
			if sprite.level < crops.crops[plantID]["growth_level"]:
				sprite.region_rect.position.x += 16
				sprite.level += 1
				check_water(tilemap.local_to_map(self.global_position))
			else:
				sprite.plant_increased()

func set_new_time(new_time:float) -> void:
	timer.stop()
	timer.set_wait_time(new_time)
	timer.start()
