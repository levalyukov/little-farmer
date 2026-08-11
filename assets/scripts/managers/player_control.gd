extends Node

# ===================================================================
# PlayerControl (player_control.gd)
# ===================================================================
# Синглтон, отвечающий за управление данными игрока: 
# чертежи, инвентарь, почта, статистика и так далее.
#
# ЗОНА ОТВЕТСТВЕННОСТИ:
# -  
#
# ОСНОВНОЙ ФУНКЦИОНАЛ:
# - 
#
# ЗАВИСИМОСТИ:
# - 
#
# ===================================================================

var mailbox:Array[int]
var inventory:Array[int]
var blueprints:Array[int]

func player_load(content:Dictionary) -> void:
    mailbox     = content["mailbox"]    if content.has("mailbox")       else []
    inventory   = content["inventory"]  if content.has("inventory")     else []
    blueprints  = content["blueprints"] if content.has("blueprints")    else []

func player_get() -> Dictionary:
    return \
    {
        "mailbox":    self.mailbox,
        "inventory":  self.inventory,
        "blueprints": [0,1,2,3,4,5,6] #self.blueprints
    }