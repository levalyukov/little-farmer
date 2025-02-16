extends Camera2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid")
@onready var player:CharacterBody2D = get_node("/root/"+main+"/Player")

const camera_speed:float = 1000.0
const max_offset_distance:float = 150.0
const center_deadzone_radius_screen:float = 550.0

const zoom_min:float = 2.0
const zoom_max:float = 10.0
const zoom_speed:float = 6.0
const zoom_tolerance:float = 0.01
const zoom_increment:float = 1.0

var current_zoom:float = 3.5
var target_zoom:float = 3.0
var is_zooming:bool = false
var is_changing_zoom:bool = false

func _process(delta) -> void:
	if !pause.paused:
		handle_zoom(delta)
		#	handle_mouse_look(delta)

func handle_zoom(delta) -> void:
	if !is_zooming && !pause.other_menu:
		if Input.is_action_just_released("mouse wheel up"):
			if current_zoom < zoom_max:
				target_zoom = min(current_zoom + zoom_increment, zoom_max)
				is_changing_zoom = true
		if Input.is_action_just_released("mouse wheel down"):
			if current_zoom > zoom_min:
				target_zoom = max(current_zoom - zoom_increment, zoom_min)
				is_changing_zoom = true

	if is_changing_zoom:
		current_zoom = lerp(current_zoom, target_zoom, zoom_speed * delta)
		if abs(current_zoom - target_zoom) < zoom_tolerance:
			current_zoom = target_zoom
			is_changing_zoom = false
		set_zoom(Vector2(current_zoom, current_zoom))

func handle_mouse_look(delta) -> void:
	var mouse_position_screen:Vector2 = get_viewport().get_mouse_position()
	var viewport_size:Vector2 = get_viewport().get_visible_rect().size
	var mouse_position:Vector2 = get_global_mouse_position()
	var player_position:Vector2 = player.global_position
	var direction:Vector2 = mouse_position - player_position
	var center_deadzone_radius_world:float = center_deadzone_radius_screen / current_zoom
	if is_mouse_inside_viewport(mouse_position_screen, viewport_size):
		if !pause.other_menu && grid.mode == grid.modes.NOTHING:
			if direction.length() > center_deadzone_radius_world:
				var movement:Vector2 = direction.normalized() * camera_speed * delta / current_zoom
				global_position += movement
				var offset_from_player:Vector2 = global_position - player_position
				if offset_from_player.length() > max_offset_distance / current_zoom:
					offset_from_player = offset_from_player.normalized() * max_offset_distance / current_zoom
					global_position = player_position + offset_from_player
			else:
				global_position = player_position
		else:
			global_position = player_position
	else:
		global_position = player_position

func is_mouse_inside_viewport(mouse_position:Vector2, viewport_size:Vector2) -> bool:
	return (
        mouse_position.x >= 0 &&
        mouse_position.y >= 0 &&
        mouse_position.x <= viewport_size.x &&
        mouse_position.y <= viewport_size.y
    )