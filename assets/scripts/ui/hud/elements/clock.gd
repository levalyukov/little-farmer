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

const seasons:Array[String] = [
	"spring", "summer", 
	"autumn", "winter"
]
var season:int = 1
var year:int = 1
var week:int = 1
var day:int = 0
var hour:int = 6
var minute:int = 1

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
	
#	func _input(_event):
#		if Input.is_action_just_pressed("space"):
#			update_season()

func clock_update() -> void:
	var day_string = tr("clock.day_lived")
	var time = str(hour) + ":" + str(minute) + "0 " + day_string + ": " + str(day+1)
	label.text = str(weeks[day]) + " " + str(time)

func get_season() -> String:
	return seasons[season]

func set_clock_value(
	season_value:int,
	year_value:int,
	week_value:int,
	day_value:int,
	hour_value:int,
	minute_value:int
	) -> void:
	year = year_value
	week = week_value
	day = day_value
	hour = hour_value
	minute = minute_value
	season = season_value
	set_season(season_value)

func time_paused(status:bool) -> void:
	timer.set_paused(status)

func time_state(status:bool) -> void:
	match status:
		true:
			timer.stop()
		false:
			timer.start()

func week_update() -> void:
	if day < weeks.size()-1:
		day += 1
	else:
		week += 1
		day = 1

func update_season() -> void:
	if season < 3:
		season += 1
	else:
		season = 0
		year += 1
	tilemap.set_atlas(seasons[season])

func set_season(target_season:int) -> void:
	tilemap.set_atlas(seasons[target_season])
	
func check_minute() -> void:
	if minute >= 0:
		minute += 1
	if minute > 5:
		minute = 0
		hour = hour + 1

func check_hour() -> void:
	if hour > 23:
		hour = 0
		week_update()
		shadow.remove_all_clouds()

func check_week() -> void:
	if week > 4:
		week = 1
		update_season()

func _on_timer_timeout() -> void:
	if !pause.paused:
		check_minute()
		check_hour()
		check_week()
		clock_update()