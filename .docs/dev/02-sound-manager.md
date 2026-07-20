# Менеджер звуков `SoundManager`

`SoundManager` - Глобальный синглтон, отвечающий за проигрывание игровых звуков. 

Проигрывать менеджер может исключительно аудиофайлы формата `.ogg`.

## Методы 

Проигрывает игровые звуки.

- `volume` - путь до звукового файла.

```gdscript
func play_sound(volume:String) -> void:
```

## Пример кода

При нажатии кнопки проигрывается звук клика по кнопке.

```gdscript
extends Control

@onready var button:Button = $Button

func _ready() -> void:
    button.pressed.connect(
        func() -> void:
            SoundManager.play_sound("ui/click")
    )
```