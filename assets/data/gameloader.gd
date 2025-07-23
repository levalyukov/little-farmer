extends Node

const GROWTH_TIME:int = 1
const MAX_GROWTH_VALUE:int = 300

var start:bool = !false
var mode:bool = false
var modal:bool = false

# Indicators
var mailbox_indicator:bool = false

# Letters Triggers
var first_empty_water_can:bool = false
var reminder_harvest:bool = false
var start_little_water:bool = false

# Plants timer
var current_greenhouse:String
var greenhouses:Dictionary = {}
var farm:Dictionary = {}
var _outside_timer:Timer

var farm_time_left:int = 0

func create_outside_timer(_name_scene:String) -> void:
    _outside_timer = Timer.new()
    _outside_timer.set_autostart(true)
    _outside_timer.wait_time = GROWTH_TIME
    _outside_timer.connect('timeout', Callable(self, '_plants_growth').bind(_name_scene))
    add_child(_outside_timer)

func check_timer() -> bool:
    if get_children().size() > 0:
        for timer in get_children():
            if timer is Timer:
                return true
    return false

func get_timer() -> Node2D:
    if get_children().size() > 0:
        for timer in get_children():
            if timer is Timer:
                return timer
    return null

func remove_timer() -> void:
    _outside_timer.wait_time = 0
    _outside_timer.stop()
    remove_child(_outside_timer)
    _outside_timer.queue_free()

func _check_greenhouse(_node_name:String) -> void:
    if greenhouses.has(_node_name): return
    else:
        greenhouses[_node_name] = {}
        greenhouses[_node_name]['time_left'] = 0

func _plants_growth(_name_scene:String) -> void:
    match _name_scene:
        'Farm':
            if !greenhouses.is_empty():
                for greenhouse in greenhouses.keys():
                    if !greenhouse.is_empty():
                        greenhouses[greenhouse]['time_left'] += 1
        _:
            if !farm.is_empty():
                farm_time_left = min(farm_time_left + 1, MAX_GROWTH_VALUE)

                if greenhouses.keys().size() > 1:
                    for greenhouse in greenhouses.keys():
                        if greenhouse != current_greenhouse:
                            greenhouses[greenhouse]['time_left'] += 1