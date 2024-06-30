extends RigidBody3D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()
