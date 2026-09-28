class_name PrefabContainer extends Node

# * В данном контексте префабы это узлы,
# * которые очень часто будут переиспользоваться.
# * Конечно, можно спокойно назвать любой игровой узел
# * префабом, но здесь префабы, в основном, несут
# * декоративный смысл, но не более.

enum PrefabType { WATERING, DUST }

const PREFABS: Dictionary = {
	PrefabType.WATERING: preload("res://assets/nodes/prefabs/watering.tscn"),
	PrefabType.DUST: preload("res://assets/nodes/prefabs/dust.tscn")
}


func add_prefab(type: PrefabType, pos: Vector2, size_rect: Vector2i = Vector2i(16, 16)) -> Node2D:
	var prefab: Node2D = null

	if PREFABS.has(type):
		prefab = PREFABS[type].instantiate()
		prefab.position = pos

		var particles: CPUParticles2D = prefab.get_node("CPUParticles2D")
		if particles && particles is CPUParticles2D:
			particles.emission_rect_extents = size_rect / 2

		self.add_child(prefab)

	return prefab
