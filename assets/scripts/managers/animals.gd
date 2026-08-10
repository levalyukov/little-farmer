extends Node2D

# @onready var scene: String = str(get_tree().root.get_child(3).name)
# @onready var balance: Control = get_node("/root/" + scene + "/UI/HUD/GameHud/Main/Bars/Balance")
# @onready var animalTimer: Timer = $AnimalTimer

# @export var animals: Dictionary
# const MAX_DISTANCE: int = 100
# enum ANIMAL_TYPE { COW, CHICKEN }

# var animalStalls: Array[Object]
# var animalsConfig: Dictionary = {
# 	ANIMAL_TYPE.CHICKEN: {"description": "chicken", "price": 100.00},
# 	ANIMAL_TYPE.COW: {"description": "cow", "price": 200.00}
# }


# func add_animal(animal: Object, house: Object) -> void:
# 	if !animal:
# 		return

# 	if !house:
# 		return

# 	if !animals.has(animal.name):
# 		animals[animal.name] = {}
# 		animals[animal.name]["node"] = animal
# 		animals[animal.name]["name"] = animal.animal_name
# 		animals[animal.name]["house"] = house.name
# 		animals[animal.name]["time"] = 14
# 		animals[animal.name]["resource"] = false
# 		animals[animal.name]["mother"] = false

# 	else:
# 		animals[animal.name]["house"] = house.name


# func remove_animal(animal: Object) -> void:
# 	if !animal:
# 		return

# 	if !animals.has(animal.name):
# 		return

# 	animals.erase(animal.name)


# func get_animal(animal: Object) -> Dictionary:
# 	var content: Dictionary = {}

# 	if has_animal(animal):
# 		content = {
# 			"name": animals[animal.name]["name"],
# 			"house": animals[animal.name]["house"],
# 			"node": animals[animal.name]["node"],
# 			"time": animals[animal.name]["time"],
# 			"resource": animals[animal.name]["resource"],
# 			"mother": animals[animal.name]["mother"]
# 		}

# 	return content


# func has_animal(animal: Object) -> bool:
# 	return animals.has(animal.name)


# func add_spawn(spawn: Object) -> void:
# 	if !spawn:
# 		return

# 	if animalStalls.has(spawn):
# 		return

# 	animalStalls.append(spawn)


# func get_spawns() -> Array[Object]:
# 	return animalStalls


# func get_animals_by_spawn(spawn: Object) -> Dictionary:
# 	var content: Dictionary = {}
# 	var index: int = 0

# 	if spawn:
# 		for i in animals:
# 			if animals[i]["house"] == spawn.name:
# 				content[index] = animals[i]
# 				index += 1

# 	return content


# func remove_spawn(_spawn: Object) -> void:
# 	var _animals = get_animals_by_spawn(_spawn)

# 	if !_spawn:
# 		return

# 	for i in _animals:
# 		_animals[i]["house"] = ""
# 		_animals[i]["node"].update_spawn()

# 	animalStalls.erase(_spawn)


# func _on_animal_timer_timeout() -> void:
# 	if animalStalls.size() == 0:
# 		return
# 	if animals.size() == 0:
# 		return

# 	for i in animals:
# 		if !animals[i]["mother"] && !animals[i]["resource"]:
# 			if animals[i]["time"] - 1 != 0:
# 				animals[i]["time"] -= 1

# 			else:
# 				animals[i]["resource"] = true
# 				if animalStalls.size() > 0:
# 					for j in animalStalls:
# 						j.get_animal_resource()
