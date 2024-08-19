extends Node3D

func _ready() -> void:
	rotation.y = randf_range(0,360)
	var scale_ = randf_range(0.75, 1.5)
	scale = Vector3(scale_, scale_, scale_)
