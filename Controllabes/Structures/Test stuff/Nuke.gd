extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var timer: Timer = $Timer

func _process(_delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_N):
		gpu_particles_3d.restart()
		gpu_particles_3d.emitting = true
		timer.start()
	if !timer.is_stopped():
		SignalManager.camera_shake.emit(1.0)
