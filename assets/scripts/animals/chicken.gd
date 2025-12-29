extends CharacterBody2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var grid:Node2D = get_node("/root/"+main+"/ConstructionManager/Grid") 
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var canvas:Node = get_node("/root/"+main+"/ShadowManager")
@onready var animalMenu:Control = get_node("/root/"+main+"/UI/Interactive/AnimalControlUI")
@onready var animalManager:Node2D = get_node("/root/"+main+"/AnimalManager")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var sprite:Sprite2D = $Sprite2D

var goingToSpawn:bool = false
var hover:bool = false;
var textures:Dictionary = {
	0:	preload("res://assets/resources/animal/chicken/chicken-0/shadow.png"),
	1: 	preload("res://assets/resources/animal/chicken/chicken-0/movement-vertical.png"),
	2: 	preload("res://assets/resources/animal/chicken/chicken-0/movement-horizontal.png"),
	3: 	preload("res://assets/resources/animal/chicken/chicken-0/idle.png")
};

@export var animalName:String
@export var SPEED:int = 12
var type:int = 0
var direction:Vector2i = Vector2i.ZERO
var movement:bool = direction != Vector2i.ZERO
var step:float = 0.0

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
	if goingToSpawn: return;

	var vector:int = randi_range(0,5)
	sprite.region_rect.position.x = 0
	match vector:
		1: 
			direction = Vector2i.UP
			sprite.texture = textures[1]
			sprite.region_rect.position.y = 0
		2: 
			direction = Vector2i.RIGHT
			sprite.texture = textures[2]
			sprite.region_rect.position.y = 0
		3: 
			direction = Vector2i.DOWN
			sprite.texture = textures[1]
			sprite.region_rect.position.y = 16
		4: 
			direction = Vector2i.LEFT
			sprite.texture = textures[2]
			sprite.region_rect.position.y = 16
		_:
			sprite.region_rect.position.x = 0 
			direction = Vector2i.ZERO

func _physics_process(_delta):
	if !animalManager: return;

	if animalManager.has_animal(self):
		var animalSpawn = animalManager.get_animal(self);
		var distance = round(global_position.distance_to(animalSpawn["house_node"].global_position));
		if distance > animalManager.MAX_DISTANCE: 
			goingToSpawn = true
			direction = Vector2i.ZERO
			var diff = animalSpawn["house_node"].global_position - global_position;
			if abs(diff.x) > 0.1: direction.x = sign(diff.x)
			else: direction.y = sign(diff.y)
			print(direction)

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
		else: goingToSpawn = false;

	if direction == Vector2i.ZERO: return
	step+=_delta
	if abs(step) > .20:
		step=0
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