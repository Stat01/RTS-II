extends Node3D

@export var size_m: int

func _ready() -> void:
	GeneralVars.setMapSize(size_m)
