extends Control

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var hud:Control = get_node("/root/"+main+"/UI/Decorative/Hud")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var cycle:CanvasModulate = get_node("/root/"+main+"/Cycle")
@onready var shadow:Node = get_node("/root/"+main+"/ShadowManager")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/clock.png")
@onready var icon:TextureRect = $Main/Margin/HBoxContainer/Icon/TextureRect
@onready var label:Label = $Main/Margin/HBoxContainer/Label/Label
@onready var timer:Timer = $Timer

const speed:float = 8

var year:int = 1
var month:int = 1
var week:int = 1
var day:int = 1
var hour:int = 2
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
	
func clock_update() -> void:
	var time = str(hour) + ":" + str(minute) + "0"
	label.text = str(weeks[day]) + " " + str(time)

func _week_update():
	if day < weeks.size() - 1:
		day += 1
	else:
		day = 0
	
func _on_timer_timeout():
	if !pause.paused:
		if minute >= 0:
			minute += 1
		if minute > 5:
			minute = 0
			hour = hour + 1
		if hour > 23:
			hour = 0
			_week_update()
			shadow.remove_all_clouds()
			await get_tree().create_timer(2.5).timeout
			shadow.change_state_position_for_clouds(randi_range(0,2),randi_range(0,2))
		clock_update()


func time_paused(status:bool) -> void:
	timer.set_paused(status)

func time_state(status:bool) -> void:
	match status:
		true:
			timer.stop()
		false:
			timer.start()

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