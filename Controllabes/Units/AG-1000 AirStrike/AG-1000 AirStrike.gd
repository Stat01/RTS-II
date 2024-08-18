extends Node3D

const GROUND_DECAL = preload("res://Effects/Decals/Impacts/ImpactMedium.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explosion: GPUParticles3D = $Explosion
@onready var damage_area: Area3D = $"damage Area"
@onready var laser: GPUParticles3D = $Laser

var damage: int = 60
var damage_type: int = 3

func _ready() -> void:
	animation_player.play("Start_pos")
	await get_tree().create_timer(3).timeout
	animation_player.play("Start")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Start":
		laser.set_emitting(false)
		await get_tree().create_timer(1).timeout
		explosion.set_emitting(true)
		var ins = GROUND_DECAL.instantiate()
		get_tree().root.add_child(ins)
		ins.global_position = global_position
		
		for child in get_children():
			if child is MeshInstance3D:
				child.set_visible(false)
		
		damage_area.set_monitoring(true)
		
		SignalManager.camera_shake.emit(6)
		
		await get_tree().create_timer(0.1).timeout
		
		for body in damage_area.get_overlapping_bodies():
			if body.has_method("reduceHealth"):
				body.reduceHealth(damage, damage_type, null)

func _on_explosion_finished() -> void:
	queue_free()

