extends Node

const MAX_VALUE:float = 300.0

var start:bool = false
var mode:bool = false
var modal:bool = false
var tracking_plants:bool = false
var time_left:float = 0.0
var timer = Timer.new()

# Indicators
var mailbox_indicator:bool = false

# Letters Triggers
var first_empty_water_can:bool = false
var reminder_harvest:bool = false

# ---

var greenhouse_caption:String = "greenhouse_1"
var greenhouse_plants:Dictionary = {}

func timer_farm_plant_start():
    time_left = 0.0
    if timer:
        var timer_created = false
        if self.get_children() != []:
            for i in self.get_children():
                if i.name == 'farm_timer':
                    timer_created = true
                    i.start()
                    break
        if !timer_created:
            self.add_child(timer)
            timer.name = "farm_timer"
            timer.wait_time = 1.0
            timer.connect("timeout", Callable(self, "on_timer_timeout"))
            timer.start()

func timer_farm_plant_stop():
    if timer:
        if timer.name == 'farm_timer':
            timer.stop()

func timer_greenhouse_plant_start():
    if greenhouse_caption != "":
        var timer_created = false
        if greenhouse_plants.has(greenhouse_caption):
            if greenhouse_plants[greenhouse_caption].has('time_left'):
                greenhouse_plants[greenhouse_caption]['time_left'] = 0
        if self.get_children() != []:
            for i in self.get_children():
                if i.name == greenhouse_caption+"_timer":
                    timer_created = true
                    i.start()
                    break
        if !timer_created:
            var greenhouse_timer = Timer.new()
            self.add_child(greenhouse_timer)
            greenhouse_timer.name = greenhouse_caption+"_timer"
            greenhouse_timer.wait_time = 2.0
            greenhouse_timer.connect("timeout", Callable(self, "on_timer_greenhouse_timeout").bind(greenhouse_caption,greenhouse_timer))
            greenhouse_timer.start()

func timer_greenhouse_plant_stop():
    if greenhouse_caption != "":
        for i in self.get_children():
            if i.name == greenhouse_caption+"_timer":
                i.stop()
                
func on_timer_timeout() -> void:
    if time_left < MAX_VALUE:
        time_left += 1.0
    else:
        if !timer.is_stopped():
            timer.stop()

func on_timer_greenhouse_timeout(greenhouse:String, timer_node:Timer) -> void:
    if !greenhouse_plants.has(greenhouse):
        greenhouse_plants[greenhouse] = {}
        greenhouse_plants[greenhouse]['time_left'] = 0.0
    else:
        if greenhouse_plants[greenhouse]['time_left'] < MAX_VALUE:
            greenhouse_plants[greenhouse]['time_left'] += 1.0
        else:
            timer_node.stop()

func create_timers() -> void:
    if greenhouse_plants != {}:
        var found = false
        for i in self.get_children():
            if i.name != 'farm_name':
                found = true
                break
        if !found:
            for plants in greenhouse_plants:
                var greenhouse_timer = Timer.new()
                self.add_child(greenhouse_timer)
                greenhouse_timer.name = plants+"_timer"
                greenhouse_timer.wait_time = 1.0
                greenhouse_timer.connect("timeout", Callable(self, "on_timer_greenhouse_timeout").bind(plants,greenhouse_timer))
                greenhouse_timer.start()