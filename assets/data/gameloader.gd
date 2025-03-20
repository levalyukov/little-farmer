extends Node

var start:bool = false
var mode:bool = false
var modal:bool = true
var tracking_plants:bool = false

var greenhouse_caption:String = "greenhouse_1"
var farm_plants:Dictionary = {}
var greenhouse_plants:Dictionary = {}
var time_left:float = 0.0
var timer = Timer.new()

func timer_farm_plant_start():
    if timer:
        self.add_child(timer)
        timer.name = "farm_timer"
        timer.wait_time = 1.0
        timer.connect("timeout", Callable(self, "on_timer_timeout").bind(timer))
        time_left = 0.0
        timer.start()

func timer_farm_plant_stop():
    if timer:
        if timer.name == 'farm_timer':
            timer.stop()
            self.remove_child(timer)

func on_timer_timeout(timer_) -> void:
    time_left += 5.0
    print(timer_.name, ': ', time_left)