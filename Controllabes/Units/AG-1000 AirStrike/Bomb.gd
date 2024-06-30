extends MeshInstance3D

@onready var trail: GPUParticles3D = $Trail
@onready var fire: GPUParticles3D = $Fire

@onready var audio_fall: AudioStreamPlayer3D = $AudioStreamPlayer3D

var once: bool
func _physics_process(_delta: float) -> void:
	if global_position.y < 1 and !once:
		once = true
		trail.set_emitting(false)
		fire.set_emitting(false)
		audio_fall.playing = false
		
		SignalManager.camera_shake.emit(0.2)
