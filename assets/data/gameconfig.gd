extends Node

var language:int = 0

var vsync:bool = false
var fullscreen:bool = true
var fps_limit:int = true
    
var general:int = 100
var music:int = 25
var nature:int = 50
var radio:int = 75

func apply():
    #   --- V-Sync
    if vsync:
        ProjectSettings.set_setting("display/window/vsync/vsync_mode", 1)
    else:
        ProjectSettings.set_setting("display/window/vsync/vsync_mode", 0)
    #   --- Full Screen Mode
    if fullscreen:
        get_window().mode = Window.MODE_FULLSCREEN
    else:
        get_window().mode = Window.MODE_WINDOWED
    #   --- FPS Limit
    match fps_limit:
        0:
            Engine.max_fps = 30
        1:
            Engine.max_fps = 60
        _:
            Engine.max_fps = 0

    #   --- Sounds
    #   General
    var normalized_value_general = clamp(general / 100.0, 0.001, 1.0)
    var target_general_db_value = 20.0 * log(normalized_value_general) / log(10.0)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Master'), target_general_db_value)
    #   Music
    var normalized_value_music = clamp(music / 100.0, 0.001, 1.0)
    var target_music_db_value = 20.0 * log(normalized_value_music) / log(10.0)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Music'), target_music_db_value)
    #   Nature
    var normalized_value_nature = clamp(nature / 100.0, 0.001, 1.0)
    var target_nature_db_value = 20.0 * log(normalized_value_nature) / log(10.0)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Nature'), target_nature_db_value)
    #   Radio
    var normalized_value_radio = clamp(radio / 100.0, 0.001, 1.0)
    var target_radio_db_value = 20.0 * log(normalized_value_radio) / log(10.0)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Radio'), target_radio_db_value)