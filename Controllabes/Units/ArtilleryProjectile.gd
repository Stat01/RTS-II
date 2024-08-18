extends CharacterBody3D

@onready var collision_area: Area3D = $"Collision Area"
@onready var collision_area_ground: Area3D = $"Collision Area Ground"
@onready var trail: GPUParticles3D = $Trail
@onready var model: MeshInstance3D = $Model

const PROJECTILE: NodePath = "res://Controllabes/Units/ArtilleryProjectile.tscn"

var shooter: CharacterBody3D
var team: int
var damage: int
var damage_type: int
var camera_shake_strength: float
var target_position: Vector3
var look_dir: Vector3

var once: bool
var going_down: bool
var stop_projectile: bool

var victims: Array[CharacterBody3D]

func initialize(shooter_: CharacterBody3D, team_: int, damage_: int, damage_type_: int, camera_shake_strength_: float, target_position_: Vector3) -> void:
	shooter = shooter_
	team = team_
	damage = damage_
	damage_type = damage_type_
	camera_shake_strength = camera_shake_strength_
	target_position = target_position_

func _physics_process(_delta: float) -> void:
	if going_down:
		velocity = (target_position - global_position).normalized() * 40
	
	if !stop_projectile:
		move_and_slide()
	
	if !once:
		once = true
		await get_tree().create_timer(0.1).timeout
		look_at(global_position + velocity)
		#going down
		if going_down:
			await get_tree().create_timer(3).timeout
			queue_free()
		#going up
		else:
			await get_tree().create_timer(1).timeout
			createDownwardProjectile()
			await get_tree().create_timer(2).timeout
			queue_free()
	
	if trail.is_emitting() == false:
		await get_tree().create_timer(0.1).timeout
		trail.set_emitting(true)

func _on_collision_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if !victims.has(body):
			victims.append(body)

func _on_collision_area_ground_body_entered(body: Node3D) -> void:
	if body is Terrain3D:
		stop_projectile = true
		global_position = Vector3(global_position.x, .5, global_position.z)
		for i in victims:
			if i != null and i is CharacterBody3D and i.has_method("getTeam") and i.getTeam() != team and i.getTeam() != 0:
				if i != null and shooter != null:
					i.reduceHealth(damage, damage_type, shooter)
		
		#particles
		await get_tree().create_timer(0.1).timeout
		EffectCreator.explosionMedium(global_position)
		model.set_visible(false)
		trail.set_emitting(false)
		
		#camera shake
		await get_tree().create_timer(0.1).timeout
		SignalManager.camera_shake.emit(camera_shake_strength)
		collision_area.set_deferred("monitoring", false)
		
		await get_tree().create_timer(2).timeout
		queue_free()

func createDownwardProjectile() -> void:
	var ins: CharacterBody3D = load(PROJECTILE).instantiate()
	
	#set projectile stats
	if shooter == null:
		ins.initialize(null, team, damage, damage_type, 0.1, target_position)
	else:
		ins.initialize(shooter, team, damage, damage_type, 0.1, target_position)
	
	get_tree().root.add_child(ins)
	ins.global_position = global_position
	ins.going_down = true
	await get_tree().create_timer(0.05).timeout
	var dir: Vector3 = (target_position - global_position).normalized()
	ins.velocity = dir * 40
