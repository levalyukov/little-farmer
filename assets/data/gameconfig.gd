extends Node

var vsync:bool = false
var fullscreen:bool = true
var fps_limit:int = true
    
var general:int = 100
var music:int = 23
var nature:int = 50

func apply():
    # V-Sync
    if vsync:
        ProjectSettings.set_setting("display/window/vsync/vsync_mode", 1)
    else:
        ProjectSettings.set_setting("display/window/vsync/vsync_mode", 0)
    # Full Screen Mode
    if fullscreen:
        get_window().mode = Window.MODE_FULLSCREEN
    else:
        get_window().mode = Window.MODE_WINDOWED
    # FPS Limit
    match fps_limit:
        0:
            Engine.max_fps = 30
        1:
            Engine.max_fps = 60
        _:
            Engine.max_fps = 0
