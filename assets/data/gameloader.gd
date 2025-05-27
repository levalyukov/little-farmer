extends Node

const MAX_VALUE:float = 300.0

var start:bool = false
var mode:bool = !false
var modal:bool = false
var tracking_plants:bool = false
var time_left:float = 0.0
var timer = Timer.new()

# Indicators
var mailbox_indicator:bool = false

# Letters Triggers
var first_empty_water_can:bool = false
var reminder_harvest:bool = false

# Plants timer