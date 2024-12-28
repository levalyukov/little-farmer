extends CanvasModulate

@onready var main:String = str(get_tree().root.get_child(1).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blackout:Control = get_node("/root/"+main+"/UI/Decorative/Blackout")
@onready var clock:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Clock")
@export var gradient_texture:GradientTexture1D

const real_seconds_per_game_minute:float = 8.0 / 10.0
const game_day_duration:float = 1440.0
const day_start:float = 300.0
const day_end:float = 1080.0

@onready var time_passed:float = clock.hour * 60.0
var value:float

func _process(delta):
    if !pause.paused:
        time_passed += (delta / real_seconds_per_game_minute)
        time_passed = fmod(time_passed, game_day_duration)
        cycle()

func cycle() -> void:
    if !pause.paused\
    && !blackout.blackouted:
        if gradient_texture && gradient_texture.gradient:
            var shifted_progress:float
            if time_passed >= day_start && time_passed < day_end:
                shifted_progress = (time_passed - day_start) / (day_end - day_start)
                value = 1.0 - shifted_progress
            else:
                if time_passed < day_start:
                    shifted_progress = (time_passed + game_day_duration - day_end) / (day_start + game_day_duration - day_end)
                else:
                    shifted_progress = (time_passed - day_end) / (day_start + game_day_duration - day_end)
                value = shifted_progress

            if time_passed >= day_start && time_passed < day_end:
                value = (sin(value * PI) + 1.0) / 2.0
            else:
                value = (1.0 - sin(value * PI)) / 2.0
            color = gradient_texture.gradient.sample(value)
            
func set_cycle_value(passed:float) -> void:
    #value = cycle_value
    time_passed = passed * 60.0

func get_cycle_value() -> float:
    return value
    
