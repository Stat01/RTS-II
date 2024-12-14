extends GPUParticles3D

func _ready() -> void:
	Settings.fog_of_war_changed.connect(enable)

func enable(i: bool) -> void:
	emitting = i
