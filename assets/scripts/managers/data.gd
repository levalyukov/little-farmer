extends Node

# =============================================================================================
# GameData (data.gd)
# =============================================================================================
# Синглтон управления игровыми данными.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# - Сохранение, загрузка, перезапись, удаление изменений на ферме игрока
# 
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - save() - Сохранение игровой карты
# - load() - Сохранение игровой карты
#
# =============================================================================================

const FILES:Dictionary = \
{
	SETTINGS = "user://settings.json"
}

func save() -> void:
	pass

func load() -> void:
	pass

func settings_save() -> void:
	var data:String = JSON.stringify(Settings.settings_get(), "\t")
	var file:FileAccess = FileAccess.open(FILES.SETTINGS, FileAccess.WRITE)
	file.store_string(data)

func settings_load() -> void:
	var file:FileAccess = FileAccess.open(FILES.SETTINGS, FileAccess.READ)
	Settings.settings_set(JSON.parse_string(file.get_as_text()))\
	if file && JSON.parse_string(file.get_as_text()) else Settings.settings_update()
