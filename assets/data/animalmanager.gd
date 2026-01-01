extends Node2D

# --- Animals Manager ---
@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var balance:Control = get_node("/root/"+main+"/UI/HUD/GameHud/Main/Bars/Balance")
@onready var animalTimer:Timer = $AnimalTimer

@export var animals:Dictionary = {};
const MAX_DISTANCE:int = 100;
enum ANIMAL_TYPE {CHICKEN, COW};
var animalStalls:Array[Object];
var animalsConfig:Dictionary = {
	ANIMAL_TYPE.CHICKEN: {
		"description": "chicken",
		"price": 100.00
	},

	ANIMAL_TYPE.COW: {
		"description": "cow",
		"price": 200.00
	}
};

func add_animal(animal:Object, house:Object) -> void:
	if !animal: return;
	if !house: return;

	if !animals.has(animal.name):
		animals[animal.name] = {};
		animals[animal.name]["node"] = animal;
		animals[animal.name]["name"] = animal.animalName;
		animals[animal.name]["house"] = house.name;
	else: animals[animal.name]["house"] = house.name;

func remove_animal(animal:Object) -> void:
	if !animal: return;
	if !animals.has(animal.name): return;
	animals.erase(animal.name);

func get_animal(animal:Object) -> Dictionary:
	var content:Dictionary = {}
	if has_animal(animal):
		content = {
			"name": animals[animal.name]["name"],
			"house": animals[animal.name]["house"],
			"node": animals[animal.name]["node"],
		};
	return content;

func has_animal(animal:Object) -> bool:
	return animals.has(animal.name);

# Добавляет постройку как место для животных
func add_spawn(spawn:Object) -> void:
	if !spawn: return;
	if animalStalls.has(spawn): return;
	animalStalls.append(spawn);

func get_spawns() -> Array[Object]:
	return animalStalls;

func get_animals_by_spawn(_spawn:Object) -> Dictionary: 
	var content:Dictionary = {};
	var index:int = 0;
	if _spawn:
		for i in animals:
			if animals[i]["house"] == _spawn.name:
				content[index] = animals[i];
				index+=1;
	return content;

func remove_spawn(_spawn:Object) -> void:
	if !_spawn: return;
	var _animals = get_animals_by_spawn(_spawn);
	print(animals)
	for i in _animals: 
		_animals[i]["house"] = "";
		_animals[i]["node"].update_spawn();
	animalStalls.erase(_spawn);
	

# В хлевах и будущих постройках такого же типа появляется их тип ресурса:
# - Куры - яйца (1 курица = 1 яйцо)
# - ///
func _on_animal_timer_timeout(): 
	if animalStalls.size() == 0: return;

	for i in animalStalls:
		i.get_animal_resource();
