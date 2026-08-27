extends Node

var letters: Dictionary = {
	1: {
		"title": "Hello, World!", 
		"description": "This is test text", 
		"author": "Developer", 
		"items": {}
	}
}


func _ready() -> void:
	letters.make_read_only()


func get_letter(letter_id: int) -> Dictionary:
	var data: Dictionary = {}

	if letters.has(letter_id):
		data.merge(letters[letter_id])

	return data
