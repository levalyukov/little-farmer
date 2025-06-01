extends Node2D

@onready var main:String = str(get_tree().root.get_child(2).name)
@onready var tip:Control = get_node("/root/"+main+"/UI/Feedback/Tooltip")
# Дети
@onready var sprite:Sprite2D = $Sprite2D
@onready var indicator:Sprite2D = $Indicator
@onready var anim:AnimationPlayer = $AnimationPlayer

var _plant_id:int = -1
var _level:int = 0
var _condition:int = 0
var _degree:int = 0
enum PHASES {
	PLANTED, 			# Посажено
	GROWING, 			# Растет
	REQUIRES_WATERING, 	# Требуется полив
	GROWED, 			# Выросло
	DEAD				# Погибло
}

# Crops config
var _caption:String = ''				# Названия культуры, передается только ключ: 'crops.carrot' -> 'Морковь'
var _growth_rate:float = 0.0			# Время роста
var _growth_max:int = 0					# Максимальный уровень роста
var _mortality:int = 0					# Смертность
var _seasons:Array = []					# Сезоны, в которые культура может жить
var _rect_x:int = 0						# Координата X прямоугольника спрайта
var _rect_y:int = 0						# Координата Y прямоугольника спрайта
var _fertilize:float = 0.0				# Процент удобрения
var _position:Vector2i = Vector2i(0,0)	# Позиция объекта на тайловой карте

var _growth_value:int = 0				# Значение, с которым 'farming.gd' манипулирует для роста растений

func plant(
		plant_id:int,
		plant_caption:String,
		plant_growth_rate:float,
		plant_growth_level_max:int,
		plant_mortality_value:int,
		plant_seasons_array:Array, 
		plant_rect_x:int,
		plant_rect_y:int,
		plant_condition:int,
		plant_level:int,
		plant_degree:int,
		plant_position:Vector2i,
		plant_fertilize_percent:int,
		plant_growth_value:int = 0
	) -> void:
	_plant_id = plant_id
	_caption = plant_caption
	_growth_rate = plant_growth_rate
	_growth_max = plant_growth_level_max
	_mortality = plant_mortality_value
	_seasons = plant_seasons_array
	_rect_x = plant_rect_x
	_rect_y = plant_rect_y
	_fertilize = plant_fertilize_percent

	_condition = plant_condition
	_level = plant_level
	_degree = plant_degree
	_position = plant_position
	self.set_position(_position)

	if plant_growth_value > 0:
		_growth_value = plant_growth_value
	else:
		_growth_value = round(plant_growth_rate - (plant_fertilize_percent / 100.0) * plant_growth_rate)

	sprite.region_rect.position.x = _rect_x
	sprite.region_rect.position.y = _rect_y

func growth() -> void:
	if _level < _growth_max:
		_level = min(_level + 1, _growth_max)
		sprite.region_rect.position.x = _rect_x + (_level * 16)
	else:
		_condition = PHASES.GROWED

func dead() -> void:
	_condition = PHASES.DEAD
	sprite.region_rect.position.y = 160
	sprite.region_rect.position.x = 0

func _get_condition_local(condition_type:int) -> String:
	match condition_type:
		0:
			return tr("plant_condition.planted")
		1:
			return tr("plant_condition.growing")
		2:
			return tr("plant_condition.requires_watering")
		3:
			return tr("plant_condition.growed")
		4:
			return tr("plant_condition.dead")
		_:
			return ""

func get_data() -> Dictionary:
	return {
		"position": _position,
		"plant_id": _plant_id,
		"caption": _caption,
		"condition": _condition,
		"fertilizer_percent": _fertilize,
		"level": _level,
		"growth_rate": _growth_rate,
		"growth_value": _growth_value,
		"level_max": _growth_max,
		"degree": _degree,
		"mortality": _mortality,
		"seasons": _seasons,
		"rect_x": sprite.region_rect.position.x,
		"rect_y": sprite.region_rect.position.y,
	}

func _on_collision_mouse_entered():
	if !tip.visible:
		if abs(_fertilize) == 0.0:
			tip.tooltip(
				tr(_caption) + '\n'
				+ tr('tooltip.plant_condition') + ": " + str(_get_condition_local(_condition))
			)
		else:
			tip.tooltip(
				tr(_caption) + '\n'
				+ tr('tooltip.plant_condition') + ": " + str(_get_condition_local(_condition)) + '\n'
				+ tr('tooltip.plant_fertilized')
			)

func _on_collision_mouse_exited():
	tip.tooltip()

func _exit_tree() -> void:
	_plant_id = 0
	_level = 0
	_condition = 0
	_degree = 0
	_caption = ''
	_growth_rate = 0.0
	_growth_max = 0
	_mortality = 0
	_seasons = []
	_rect_y = 0
	_fertilize = 0.0
	_growth_value = 0