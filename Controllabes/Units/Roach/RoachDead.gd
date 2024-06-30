extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("ArmatureAction_001")
	global_rotation.y = randf_range(0, 2*PI)
	await get_tree().create_timer(60).timeout

func _process(_delta: float) -> void:
	global_position.y -= 0.0001
