extends Sprite3D

func refreshNoise() -> void:
	set("texture/noise/seed", randi_range(0,1024))
