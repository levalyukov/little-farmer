extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var hud:Control = get_node("/root/"+main+"/UI/Decorative/Hud")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var cycle:CanvasModulate = get_node("/root/"+main+"/Cycle")
@onready var shadow:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/clock.png")
@onready var icon:TextureRect = $Main/Margin/HBoxContainer/Icon/TextureRect
@onready var label:Label = $Main/Margin/HBoxContainer/Label/Label
@onready var timer:Timer = $Timer

const speed:float = 8

const seasons:Array[String] = ["spring", "summer", "autumn", "winter"]
var season:int = 0
var year:int = 1
var month:int = 1
var week:int = 1
var day:int = 1
var hour:int = 7
var minute:int = 0

var weeks:Array[String] = [
		tr("mon.clock"), tr("tue.clock"), tr("wed.clock"), 
		tr("thu.clock"), tr("fri.clock"), tr("sat.clock"), 
		tr("sun.clock")
	]

func _ready():
	icon.texture = sprite
	timer.wait_time = speed
	timer.set_paused(false)
	timer.start()
	
func _input(_event):
	if Input.is_action_just_pressed("space"):
		update_season()

func clock_update() -> void:
	var time = str(hour) + ":" + str(minute) + "0"
	label.text = str(weeks[day]) + " " + str(time)

func get_season() -> String:
	return seasons[season]

func set_clock_value(
	year_value:int,
	month_value:int,
	week_value:int,
	day_value:int,
	hour_value:int,
	minute_value:int
	) -> void:
	year = year_value
	month = month_value
	week = week_value
	day = day_value
	hour = hour_value
	minute = minute_value

func time_paused(status:bool) -> void:
	timer.set_paused(status)

func time_state(status:bool) -> void:
	match status:
		true:
			timer.stop()
		false:
			timer.start()

func week_update() -> void:
	if day < weeks.size() - 1:
		day += 1
	else:
		day = 1

func update_season() -> void:
	if season < 3:
		season += 1
	else:
		season = 0
	tilemap.update_atlas(seasons[season])

func set_season(target_season:int) -> void:
	if seasons.has(target_season):
		tilemap.update_atlas(seasons[target_season])
	
func _on_timer_timeout() -> void:
	if !pause.paused:
		if minute >= 0:
			minute += 1
		if minute > 5:
			minute = 0
			hour = hour + 1
		if hour > 23:
			hour = 0
			week_update()
			shadow.remove_all_clouds()
		if day > 28:
			day = 1
			update_season()
		clock_update()
