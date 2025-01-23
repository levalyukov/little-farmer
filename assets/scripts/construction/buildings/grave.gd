extends Node2D

@onready var sprite:Sprite2D = $Sprite2D
var graves:Dictionary = {
	1: {
		'sprite' = preload('res://assets/resources/buildings/graves/grave_1/object_0.png'),
		'position' = Vector2i(),
		'dialog' = {
			'caption' = tr('Могила'),
			'mainContent' = [
				'Добрый день, юный садовод! Меня зовут Добрыня — местный торговец и садовод по совместительству.\n\nУ меня ты можешь приобрести семена на сезон, а также полезные вещи для сада.',
			], 
			'buttonCaptions' = {
				0:['Интересно узнать твой ассортимент [Торговля]','Всего доброго! [Закрыть]'],
			},
			'buttonFunc' = {
				0:[2,0],
			}
		}
	},
}

func create_gameobj(id:int, vector_position:Vector2i, mainText:String) -> void:
	if graves.has(id):
		pass