extends Control

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var hud:Control = get_node("/root/"+main+"/UI/Decorative/Hud")
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
@onready var cycle:CanvasModulate = get_node("/root/"+main+"/Cycle")
@onready var shadow:Node = get_node("/root/"+main+"/ShadowManager")
@onready var tilemap:TileMap = get_node("/root/"+main+"/Tilemap")
@onready var sprite:CompressedTexture2D = load("res://assets/resources/ui/interactive/hud/clock.png")
@onready var icon:TextureRect = $Margin/HBoxContainer/Icon/TextureRect
@onready var label:Label = $Margin/HBoxContainer2/Label/Label
@onready var timer:Timer = $Timer

var audio = AudioStreamPlayer.new()
#	var random_prefab = AudioStreamPlayer.new()
#	const random_prefab_time:int = 48
#	var prefabs:Dictionary = {
#		'spring': {},
#		'summer': {
#			'day': [
#				load('res://assets/sounds/nature/short_audio/summer/day/'),
#			],
#			'night': [
#				load('res://assets/sounds/nature/short_audio/summer/night/'),
#			]
#		}
#	}

var spring_day_sound = preload('res://assets/sounds/nature/spring_day.ogg')
var spring_night_sound = load('res://assets/sounds/nature/spring_night.ogg')
const spring_day_sound_end:int = 19
const spring_night_sound_end:int = 6

var summer_day_sound = load('res://assets/sounds/nature/summer_day.ogg')
var summer_night_sound = load('res://assets/sounds/nature/summer_night.ogg')
const summer_day_sound_end:int = 19
const summer_night_sound_end:int = 6

var autumn_day_sound = load('res://assets/sounds/nature/autumn_day.ogg')
var autumn_night_sound = load('res://assets/sounds/nature/autumn_night.ogg')
const autumn_day_sound_end:int = 19
const autumn_night_sound_end:int = 6

var winter_day_sound = load('res://assets/sounds/nature/winter_day.ogg')
var winter_night_sound = load('res://assets/sounds/nature/winter_night.ogg')
const winter_day_sound_end:int = 19
const winter_night_sound_end:int = 6

const speed:float = 8
const day_end:int = 23

var year:int = 1
var week:int = 0
var day:int = 1
var hour:int = 7
var minute:int = 0

var season:int = 0
const season_change:int = 1
const seasons:Array[String] = [
	"spring", "summer", 
	"autumn", "winter"
]

var weeks:Array[String] = [
		tr("Пн."), tr("Вт."), tr("Ср."), 
		tr("Чт."), tr("Пт."), tr("Сб."), 
		tr("Вс.")
	]

func _ready():
	tilemap.set_atlas(seasons[season])
	icon.texture = sprite
	timer.wait_time = speed
	timer.set_paused(false)
	timer.start()
	self.add_child(audio)
	audio.bus = 'Nature'
	#	self.add_child(random_prefab)
	#	random_prefab.bus = 'Nature'
	start_nature_sounds()

func _process(_delta):
	if !pause.paused:
		if audio.get_stream_paused():
			audio.set_stream_paused(false)
		start_nature_sounds()
	else:
		if !audio.get_stream_paused():
			audio.set_stream_paused(true)

func start_nature_sounds() -> void:
	match get_season():
		'spring':
			if range(spring_night_sound_end, spring_day_sound_end).has(hour):
				if audio.stream == spring_night_sound || !audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = spring_day_sound
					audio.play()
			else:
				if !audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = spring_night_sound
					audio.play()
		'summer':
			if range(summer_night_sound_end, summer_day_sound_end).has(hour):
				if audio.stream == summer_night_sound || !audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = summer_day_sound
					audio.play()
			else:
				if !audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = summer_night_sound
					audio.play()
		'autumn':
			if range(autumn_night_sound_end, autumn_day_sound_end).has(hour):
				if audio.stream != autumn_day_sound && audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = autumn_day_sound
					audio.play()
			else:
				if !audio.is_playing():
					audio.stop()
				#	audio.volume_db = 0.0
				#	audio.stream = autumn_night_sound
				#	audio.play()
		'winter':
			if range(winter_night_sound_end, winter_day_sound_end).has(hour):
				if !audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = winter_day_sound
					audio.play()
			else:
				if !audio.is_playing():
					audio.stop()
					audio.volume_db = 0.0
					audio.stream = winter_day_sound
					audio.play()

func clock_update() -> void:
	var day_string = tr("День")
	var time = str(hour) + ":" + str(minute) + "0; " + day_string + ": " + str(day+1)
	label.text = str(weeks[day]) + " " + str(time)

func get_season() -> String:
	return seasons[season]

func get_hour() -> int:
	return hour

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
	if main == "Farm"\
	|| main == "Village":
		tilemap.set_atlas(seasons[target_season])
	
func check_minute() -> void:
	if minute >= 0:
		minute += 1
	if minute > 5:
		minute = 0
		hour = hour + 1

func check_hour() -> void:
	if hour > day_end:
		hour = 0
		week_update()
		if main == "Farm"\
		|| main == "Village":
			shadow.remove_all_clouds()

func check_week() -> void:
	if week > season_change:
		week = 1
		update_season()

func _on_timer_timeout() -> void:
	if !pause.paused:
		check_minute()
		check_hour()
		check_week()
		clock_update()