extends Control

# --- Animal Control UI ---

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var pause:Control = get_node("/root/"+main+"/UI/Interactive/Pause")
@onready var blur:Control = get_node("/root/"+main+"/UI/Decorative/Blur")
@onready var animalManager:Node2D = get_node("/root/"+main+"/AnimalManager")
@onready var cursor:Node2D = get_node("/root/"+main+"/UI/HUD/Cursor")
@onready var notice:Control = get_node("/root/"+main+"/UI/Feedback/Notifications")

@onready var animalButton:PackedScene = preload("res://assets/nodes/animal_button.tscn");
@onready var animalIcon:TextureRect = $Background/MarginContainer/HBoxContainer/MarginContainer/AnimalInfoContainer/AnimalIcon/TextureRect;
@onready var animalName:Label = $Background/MarginContainer/HBoxContainer/MarginContainer/AnimalInfoContainer/AnimalName/Label;
@onready var animalDescription:RichTextLabel = $Background/MarginContainer/HBoxContainer/MarginContainer/AnimalInfoContainer/AnimalDescription/Label;
@onready var animalButtonSell:Button = $Background/MarginContainer/HBoxContainer/MarginContainer/AnimalInfoContainer/AnimalManipulation/VBoxContainer/ButtonAnimalSell;
@onready var animalButtonChangeStall:Button = $Background/MarginContainer/HBoxContainer/MarginContainer/AnimalInfoContainer/AnimalManipulation/VBoxContainer/ButtonChangeStall;
@onready var animalButtonContainer:VBoxContainer = $Background/MarginContainer/HBoxContainer/AllStalsContainer/NinePatchRect/ScrollContainer/VBoxContainer
@onready var animalButtonClose:Button = $CloseButton
@onready var animation:AnimationPlayer = $AnimationPlayer

var opened:bool = false
var currentAnimal:Object = null;

func open(animal:Object) -> void:
  opened = true;
  if blur: blur.blur(true);
  if animation: animation.play("open");
  if animal: currentAnimal = animal;
  _get_all_stalls();
  _set_info();

func close() -> void:
  if animation: animation.play("close");
  if blur: blur.blur(false);
  opened = false;
  currentAnimal = null;

func _get_all_stalls() -> void: 
  if !animalManager: return;
  if !animalButtonContainer: return;

  if animalButtonContainer.get_children().size() > 0:
    for i in animalButtonContainer.get_children():
      animalButtonContainer.remove_child(i)

  if animalManager.get_spawns().size() == 0: 
    var empty:Label = Label.new();
    empty.text = "\n" + tr("animal.control.empty_stalls");
    empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
    animalButtonContainer.add_child(empty);
    return;

  for i in animalManager.get_spawns():
    var button = animalButton.instantiate();
    animalButtonContainer.add_child(button);
    if button.buttonSource: button.buttonSource.connect("pressed", Callable(self, "_change_spawn").bind(currentAnimal,i))
    if i: if i.sprite: button.change_icon(i.sprite.get_texture()); #! Fix this
    
    if animalManager.get_animal(currentAnimal).size() > 0:
      if animalManager.get_animal(currentAnimal).has("house"):
        if animalManager.get_animal(currentAnimal)["house"] == i.name: button.buttonSource.disabled = true;

    match i.blueprint_id:
      4: button.change_name(tr("object.animal_stall.caption"));
      _: button.change_name("???");

func _change_spawn(_animal:Object, _spawn:Object) -> void:
  if !animalManager: return;
  if !_animal: return;
  if !_spawn: return;

  animalManager.add_animal(_animal, _spawn);
  _animal.update_spawn();
  if notice: notice.create_notice(animalManager.get_animal(_animal)["name"]+" "+tr("animal.notice.has_been_moved"));
  close();

func _set_info() -> void:
  if !animalManager: return;
  if !currentAnimal: return;
  if !animalName: return;
  if !animalDescription: return;
  
  if animalManager.get_animal(currentAnimal).size() == 0:
    animalName.text = currentAnimal.animalName;
    animalDescription.text = animalManager.animalsConfig[currentAnimal.type]["description"]
  else: animalName.text = animalManager.get_animal(currentAnimal)["name"];

func _reset_data() -> void: pass
func _check_window() -> void:
  visible = opened
  if pause: pause.other_menu = opened

# -----

func _on_audio_finished(audio:AudioStreamPlayer) -> void: audio.queue_free()
func _audio_play(_ogg:String) -> void:
  var audio = AudioStreamPlayer.new()
  self.add_child(audio)
  audio.connect("finished", Callable(self, "_on_audio_finished").bind(audio))
  audio.stream = load('res://assets/sounds/ui/'+_ogg+'.ogg')
  audio.play()

func _on_close_button_pressed() -> void: close(); _audio_play("click")
func _on_close_button_mouse_entered(): if cursor: cursor.set_cursor(cursor.states.ACTIVE); _audio_play("hover")
func _on_close_button_mouse_exited(): if cursor: cursor.set_cursor(cursor.states.DEFAULT);