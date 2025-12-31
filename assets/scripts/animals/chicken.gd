extends CharacterBody2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var animalMenu:Control = get_node("/root/"+main+"/UI/Interactive/AnimalControlUI")
@onready var building:Node2D = get_node("/root/"+main+"/ConstructionManager")
@onready var animalManager:Node2D = get_node("/root/"+main+"/AnimalManager")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var house:Node2D = get_node("/root/"+main+"/ConstructionManager/house")
@onready var sprite:Sprite2D = $Sprite2D
@onready var timer:Timer = $Timer

var goingToSpawn:bool = false
var hover:bool = false;
var textures:Dictionary = {
	0:	preload("res://assets/resources/animal/chicken/chicken-0/shadow.png"),
	1: 	preload("res://assets/resources/animal/chicken/chicken-0/movement-vertical.png"),
	2: 	preload("res://assets/resources/animal/chicken/chicken-0/movement-horizontal.png"),
	3: 	preload("res://assets/resources/animal/chicken/chicken-0/idle.png"), # for icon
	4: 	preload("res://assets/resources/animal/chicken/chicken-0/sitting.png"),
	5: 	preload("res://assets/resources/animal/chicken/chicken-0/eating.png")
};

@export var animalName:String
@export var SPEED:int = 12
var ANIMATION_SPEED:float = .2;
var vector:int = 0;
var type:int = 0
var direction:Vector2i = Vector2i.ZERO
var movement:bool = direction != Vector2i.ZERO
var step:float = 0.0
var currentSpawn:Node2D = null;

func _input(event):
	if event is InputEventMouseButton\
	&& event.button_index == MOUSE_BUTTON_LEFT\
	&& event.is_pressed()\
	&& !blur.state\
	&& grid.mode == grid.modes.NOTHING\
	&& hover:
		animalMenu.open(self)
		if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _ready():
	if animalManager: type = animalManager.ANIMAL_TYPE.CHICKEN;

func _on_timer_timeout():
	if !timer:return;
	if !pause: return;
	if goingToSpawn: return;

	if !pause.paused:
		timer.wait_time = randf_range(8,16);
		vector = randi_range(0,6);
		sprite.region_rect.position.x = 0;
		match vector:
			1: 
				direction = Vector2i.UP
				sprite.texture = textures[1]
				sprite.region_rect.position.y = 0;
				ANIMATION_SPEED = .2;
			2: 
				direction = Vector2i.RIGHT
				sprite.texture = textures[2]
				sprite.region_rect.position.y = 0;
				ANIMATION_SPEED = .2;
			3: 
				direction = Vector2i.DOWN
				sprite.texture = textures[1]
				sprite.region_rect.position.y = 16;
				ANIMATION_SPEED = .2;
			4: 
				direction = Vector2i.LEFT
				sprite.texture = textures[2]
				sprite.region_rect.position.y = 16;
				ANIMATION_SPEED = .2;
			5: # sitting
				timer.wait_time = randf_range(16,64);
				sprite.texture = textures[4]
				if direction == Vector2i.LEFT: sprite.region_rect.position.y = 16;
				elif direction == Vector2i.RIGHT: sprite.region_rect.position.y = 0;
				else: sprite.region_rect.position.y = 0;
				direction = Vector2i.ZERO;
				ANIMATION_SPEED = .2;
			6: # eating
				timer.stop()
				timer.wait_time = randf_range(8,16);
				timer.start()
				sprite.texture = textures[5]
				if direction == Vector2i.LEFT: sprite.region_rect.position.y = 16;
				elif direction == Vector2i.RIGHT: sprite.region_rect.position.y = 0;
				else: sprite.region_rect.position.y = 0;
				direction = Vector2i.ZERO;
				ANIMATION_SPEED = .1;
			_:
				sprite.region_rect.position.x = 0 
				direction = Vector2i.ZERO

func _get_spawn(_name:String) -> Node2D:
	if !building: return;

	if building.get_children().size() > 0:
		for i in building.get_children():
			if i.name == _name: return i;
	return null;

func update_spawn() -> void:
	currentSpawn = _get_spawn(animalManager.get_animal(self)["house"]);

func _physics_process(delta):
	if !house: return;
	if !animalManager: return;
	if !pause: return;
	
	if !pause.paused:
		if currentSpawn:
			if round(global_position.distance_to(currentSpawn.global_position)) > animalManager.MAX_DISTANCE:
				goingToSpawn = true
				direction = Vector2i.ZERO
				if abs(ANIMATION_SPEED) < .2: ANIMATION_SPEED = .2;
				var diff = currentSpawn.global_position - global_position;
				if abs(diff.x) > 0.25: direction.x = sign(diff.x)
				else: direction.y = sign(diff.y)
				match direction:
					Vector2i.UP:
						# sprite.region_rect.position.x = 0;
						sprite.region_rect.position.y = 0;
						sprite.texture = textures[1];
					Vector2i.RIGHT:
						# sprite.region_rect.position.x = 0;
						sprite.region_rect.position.y = 0;
						sprite.texture = textures[2];
					Vector2i.DOWN:
						# sprite.region_rect.position.x = 0;
						sprite.region_rect.position.y = 16;
						sprite.texture = textures[1];
					Vector2i.LEFT:
						# sprite.region_rect.position.x = 0;
						sprite.region_rect.position.y = 16;
						sprite.texture = textures[2];
			else: if goingToSpawn: goingToSpawn = false;
		else: 
			if house:
				if round(global_position.distance_to(house.global_position)) > animalManager.MAX_DISTANCE*2.5:
					goingToSpawn = true
					direction = Vector2i.ZERO
					var diff = house.global_position - global_position;
					if abs(diff.x) > 0.25: direction.x = sign(diff.x)
					else: direction.y = sign(diff.y)
					match direction:
						Vector2i.UP:
							sprite.texture = textures[1]
							sprite.region_rect.position.y = 0
						Vector2i.RIGHT:
							sprite.texture = textures[2]
							sprite.region_rect.position.y = 0
						Vector2i.DOWN:
							sprite.texture = textures[1]
							sprite.region_rect.position.y = 16
						Vector2i.LEFT:
							sprite.texture = textures[2]
							sprite.region_rect.position.y = 16
				else: if goingToSpawn: goingToSpawn = false;

		if (direction == Vector2i.ZERO) && (vector != 6): return;
		step+=delta;
		if abs(step) > ANIMATION_SPEED:
			step = 0;
			if sprite.region_rect.position.x + 16 > sprite.texture.get_size().x-16:
				sprite.region_rect.position.x = 0
			else: sprite.region_rect.position.x += 16
		velocity = direction * SPEED
		move_and_slide()

func _on_area_2d_mouse_entered():
	if !blur.state && grid.mode == grid.modes.NOTHING:
		hover = true;
		if cursor: cursor.set_cursor(cursor.states.ACTIVE)

func _on_area_2d_mouse_exited():
	hover = false;
	if cursor: cursor.set_cursor(cursor.states.DEFAULT)

func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("Entered: ",area);
