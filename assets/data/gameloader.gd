extends Node

var start:bool = false
var mode:bool = false
var modal:bool = true
var greenhouse_caption:String = "greenhouse_1"
var farm_plants:Dictionary = {}
var greenhouse_plants:Dictionary = {}
var time_left:float = 0.0
var timer = Timer.new()

func timer_plant_start():
    if farm_plants != {}:
        print(timer)
        if timer:
            self.add_child(timer)
            timer.wait_time = 1.0
            timer.connect("timeout", Callable(self, "on_timer_timeout"))
            timer.start()

func timer_plant_stop():
    if timer:
        timer.stop()

func on_timer_timeout() -> void:
    time_left += 5.0
    print(time_left)