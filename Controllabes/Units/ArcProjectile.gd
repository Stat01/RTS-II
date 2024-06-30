extends RigidBody3D

@onready var collision_area: Area3D = $"Collision Area"
@onready var collision_area_ground: Area3D = $"Collision Area Ground"
@onready var trail: GPUParticles3D = $Trail
@onready var impact: GPUParticles3D = $Impact
@onready var model: MeshInstance3D = $Model

var shooter: CharacterBody3D
var team: int
var damage: int
var damage_type: int
var camera_shake_strength: float
var once: bool

var counter: int = 0

var exploded: bool

var victims: Array[CharacterBody3D]

func initialize(shooter_: CharacterBody3D, team_: int, damage_: int, damage_type_: int, camera_shake_strength_: float) -> void:
	shooter = shooter_
	team = team_
	damage = damage_
	damage_type = damage_type_
	camera_shake_strength = camera_shake_strength_

func _physics_process(_delta: float) -> void:
	
	look_at(global_position + linear_velocity)
	
	if !once:
		await get_tree().create_timer(.1).timeout
		trail.emitting = true
		#lifetime
		once = true
		await get_tree().create_timer(5).timeout
		queue_free()

func _on_collision_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if !victims.has(body):
			victims.append(body)


func _on_collision_area_ground_body_entered(body: Node3D) -> void:
	if !exploded:
		exploded = true
		if body is Terrain3D:
			global_position = Vector3(global_position.x, 0.2, global_position.z)
			impact.global_position = global_position
			for i in victims:
				if i != null and i is CharacterBody3D and i.has_method("getTeam") and i.getTeam() != team and i.getTeam() != 0:
					if i != null and shooter != null:
						i.reduceHealth(damage, damage_type, shooter)
			
			#particles
			impact.set_emitting(true)
			model.set_visible(false)
			trail.set_emitting(false)
			
			freeze = true
			
			#camera shake
			await get_tree().create_timer(0.1).timeout
			SignalManager.camera_shake.emit(camera_shake_strength)
			collision_area.set_deferred("monitoring", false)
			
			await get_tree().create_timer(2).timeout
			queue_free()
