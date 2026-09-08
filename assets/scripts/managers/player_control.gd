extends Node

var balance: int = 0
var mailbox: Dictionary = {}
var inventory: Dictionary = {}
var blueprints: Dictionary = \
{
	Blueprints.BlueprintsType.BUILDINGS: [1, 2, 3, 4, 5, 6, 7, 8, 9],
	Blueprints.BlueprintsType.TERRAINS: [1, 2, 3, 4, 5, 6, 7, 8, 9]
}


func player_load(content: Dictionary) -> void:
	mailbox = content["mailbox"] if content.has("mailbox") else []
	inventory = content["inventory"] if content.has("inventory") else []
	blueprints = content["blueprints"] if content.has("blueprints") else {}


func player_get() -> Dictionary:
	return {
		"mailbox": self.mailbox,
		"inventory": self.inventory,
		"blueprints":
		{
			Blueprints.BlueprintsType.BUILDINGS: self.blueprints[Blueprints.BlueprintsType.BUILDINGS],
			Blueprints.BlueprintsType.TERRAINS: self.blueprints[Blueprints.BlueprintsType.TERRAINS],
		}
	}
