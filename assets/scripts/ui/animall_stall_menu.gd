extends Control

@onready var main:String = str(get_tree().root.get_child(2).name);
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur");
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause");
@onready var animalManager:Node2D = get_node("/root/"+main+"/AnimalManager");
@onready var animation:AnimationPlayer = $AnimationPlayer;
@onready var node:PackedScene = preload("res://assets/nodes/animal_button.tscn");
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")

@onready var mainContainer:VBoxContainer = $NinePatchRect/HBoxContainer/MarginContainer/NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer;

var opened:bool = false
var currentSpawn:Node2D = null

func open(spawn:Object) -> void:
	opened = true;
	if spawn: currentSpawn = spawn;
	if blur: blur.blur(true);
	if animation: animation.play("open");
	_get_animals();

func close() -> void:
	opened = !true;
	currentSpawn = null;
	if blur: blur.blur(!true);
	if animation: animation.play("close");

# Создает кнопки для манипуляции с животными в хлеве.
func _get_animals():
	if !mainContainer: return;
	if !animalManager: return;

	var animalsOfStall:Dictionary = animalManager.get_animals_by_spawn(currentSpawn);

	if mainContainer.get_children().size() > 0:
		for i in mainContainer.get_children():
			mainContainer.remove_child(i);

	if animalsOfStall.size() == 0:
		var label:Label = Label.new();
		label.text = "\n" + tr("animal.menu.empty") # Хлев/птичник пуст, позже нужно доработать после добавления птичника
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		mainContainer.add_child(label);
		return;

	for i in animalsOfStall:
		var button:Control = node.instantiate();
		if button:
			mainContainer.add_child(button);
			if button:
				if animalsOfStall[i]["node"].textures[3]: button.change_icon(animalsOfStall[i]["node"].textures[3]);
				if animalsOfStall[i]["name"]: button.change_name(animalsOfStall[i]["name"]);

func _on_close_button_pressed(): close();
func _on_close_button_mouse_entered(): if cursor: cursor.set_cursor(cursor.states.ACTIVE)
func _on_close_button_mouse_exited(): if cursor: cursor.set_cursor(cursor.states.DEFAULT)
func _reset_data(): pass;
func _check_window(): 
	visible = opened
	if pause: pause.other_menu = opened