extends CharacterBody3D

@onready var collision_area: Area3D = $"Collision Area"
@onready var trail: GPUParticles3D = $Trail
@onready var impact: GPUParticles3D = $Impact
@onready var model: MeshInstance3D = $Model

var shooter: CharacterBody3D
var team: int
var damage: int
var damage_type: int
var camera_shake_strength: float
var look_dir: Vector3
var once: bool

func initialize(shooter_: CharacterBody3D, team_: int, damage_: int, damage_type_: int, camera_shake_strength_: float) -> void:
	shooter = shooter_
	team = team_
	damage = damage_
	damage_type = damage_type_
	camera_shake_strength = camera_shake_strength_

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	if !once:
		look_at(look_dir)
		await get_tree().create_timer(0.05).timeout
		trail.emitting = true
		#lifetime
		once = true
		await get_tree().create_timer(5).timeout
		queue_free()

func _on_collision_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("getTeam") and body.getTeam() != team and body.getTeam() != 0:
		if body != null and shooter != null:
			body.reduceHealth(damage, damage_type, shooter)
		collision_area.set_deferred("monitoring", false)
		impact.set_emitting(true)
		model.set_visible(false)
		
		#camera shake
		await get_tree().create_timer(0.1).timeout
		SignalManager.camera_shake.emit(camera_shake_strength)
		
		await get_tree().create_timer(2).timeout
		queue_free()
