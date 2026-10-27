extends Sprite2D

@export var spring: CompressedTexture2D
@export var summer: CompressedTexture2D
@export var autumn: CompressedTexture2D
@export var winter: CompressedTexture2D
@export var type: NatureManager.NatureType


func _ready() -> void:
	if type not in NatureManager.SHADER_DISABLE && NatureManager.SHADER_SOURCE:
		var shader_material: ShaderMaterial = ShaderMaterial.new()
		shader_material.shader = NatureManager.SHADER_SOURCE
		self.material = shader_material
		self.material = self.material.duplicate()


func update(season: WorldCycle.Season) -> void:
	match season:
		WorldCycle.Season.SPRING:
			self.texture = spring
		WorldCycle.Season.SUMMER:
			self.texture = summer
		WorldCycle.Season.AUTUMN:
			self.texture = autumn
		WorldCycle.Season.WINTER:
			self.texture = winter
		_:
			pass

	if self.material:
		self.material.set_shader_parameter("amplitude", NatureManager.AMPLITUDE_COEFFICIENT[season])
		self.material.set_shader_parameter("time_scale", NatureManager.TIME_SCALE_COEFFICIENT[season])
		self.material.set_shader_parameter("noise_scale", NatureManager.NOISE_SCALE_COEFFICIENT[season])
