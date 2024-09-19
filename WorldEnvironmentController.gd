extends WorldEnvironment

@onready var directional_light_3d: DirectionalLight3D = $"../DirectionalLight3D"

func _ready() -> void:
	Settings.shadow_quality_changed.connect(changeShadowQuality)
	Settings.shadow_distance_changed.connect(changeShadowDistance)

func changeShadowQuality(i: int) -> void:
	if i > 0:
		directional_light_3d.shadow_enabled = true
		directional_light_3d.directional_shadow_mode = i - 1
		return
	directional_light_3d.shadow_enabled = false

func changeShadowDistance(i: float) -> void:
	directional_light_3d.directional_shadow_max_distance = i
