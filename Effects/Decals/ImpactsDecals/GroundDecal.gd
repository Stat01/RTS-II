extends Decal

func _ready() -> void:
	global_rotation.y = randf_range(0,2*PI)
	await get_tree().create_timer(120).timeout
	queue_free()
