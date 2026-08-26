# <p align=center>Little Farmer</p>

![screenshot](assets/screenshot-2025-03-29-119964.png)

> _В вашем распоряжении заброшенный земельный участок размером 56x36 клеток. Развивайте, украшайте и вдохновляйтесь — здесь нет правил, только ваша фантазия!_

Little Farmer - 2D Top-Down пиксельная симулятор фермерства, разработанная на игровом движке Godot при помощи `GDScript`.

## Содержание

1. Основное (Вы здесь)
2. [Интерфейс](./01-ui.md)
3. [Строительство](./02-building.md)
4. [Растениеводство](./03-plants.md)
5. [Торговля](./04-trading.md)

## Инструментарий

- Игровой движок: [Godot v4.2.2](https://godotengine.org/download/archive/4.2.2-stable/)
- Графический редактор: [Aseprite](https://aseprite.org/)
- Редактор кода: [Visual Studio Code](https://code.visualstudio.com/)
- Музыкальный редактор: [Fl Studio 12](https://www.image-line.com/)

## Структура проекта

```python
little-farmer/
├── assets/
│   ├── local/              # Локализация
│   ├── nodes/              # Игровые объекты
│   ├── resourses/          # Текстуры и шрифты
│   ├── scripts/            # Скрипты
│   ├── shaders/            # Шейдеры Godot
│   └── sounds/             # Звуки и музыка
├── docs/                   # <- Вы здесь
│   └── dev/                # Документация для разработчиков
├── levels/                 # Игровые локации
│   ├── farm.tscn           # Ферма
│   ├── menu.tscn           # Главное меню
│   ├── greenhouse.tscn     # Теплица
│   └── village.tscn        # Деревня
├── .gitattributes
├── .gitignore
├── LICENSE
├── CONTRIBUTING.md
└── README.md
```
