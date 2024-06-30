extends "res://Controllabes/Units/Unit.gd"

@onready var turret_base: MeshInstance3D = $Base/Turret_Swivel

@onready var barrel: MeshInstance3D = $Base/Turret_Swivel/Turret_Base/Turret/Barrel_Elevation

@onready var casing_ejectionport: Node3D = $Base/Turret_Swivel/Turret_Base/Turret/CasingEjectionport

@onready var barrel_pos: Node3D = $Base/Turret_Swivel/Turret_Base/Turret/Barrel_Elevation/Barrel/Barrelpos

@onready var default_turret_rot_pos: Node3D = $DefaultTurretPos

@onready var barrel_dir:Node3D = $Base/Turret_Swivel/Turret_Base/Turret/barrel_dir

@onready var animation_player_barrel: AnimationPlayer = $AnimationPlayerBarrel

#@onready var animation_player_tracks: AnimationPlayer = $AnimationPlayerTracks

const PROJECTILE = preload("res://Controllabes/Units/ArtilleryProjectile.tscn")
const CASING = preload("res://Controllabes/Units/AT-12 Gladiator/Casing.tscn")

var attack_cooldown: bool

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	turnTurret()
	
	#if getState() != 0:
	#	animation_player_tracks.play("Tracks")

#why dis exist?
#func smoothTurn(look_pos: Vector3, target_node: Node, rot_speed: float) -> void:
#	if getState() != ATTACKMOVE or global_position.distance_to(target_position) > attack_range:
#		print("turniong")
#		super.smoothTurn(look_pos, target_node, rot_speed)

func turnTurret() -> void:
	if !getDetectedTargets().is_empty():
		if getCurrentTarget() != null and getCurrentTarget().getVisibleBy().has(self):
			smoothTurn(Vector3(getTargetPosition().x, turret_base.global_position.y, getTargetPosition().z), turret_base, 0.1)
			var dir: Vector3 = (target_position - global_position).normalized()
			dir.y += 5
			dir = dir.normalized() * 100
			smoothTurn(dir, barrel, 0.1)
			barrel.rotation.y = 0
		else :
			var trgt = getDetectedTargets()[0]
			smoothTurn(Vector3(trgt.global_position.x, turret_base.global_position.y, trgt.global_position.z), turret_base, 0.1)
			var dir: Vector3 = (target_position - global_position).normalized()
			dir.y += 5
			dir = dir.normalized() * 100
			smoothTurn(dir, barrel, 0.1)
			barrel.rotation.y = 0
	else:
		smoothTurn(default_turret_rot_pos.global_position, turret_base, 0.05)
		smoothTurn(barrel_dir.global_position, barrel, 0.05)

func attack(_unit: CharacterBody3D) -> void:
	if !attack_cooldown:
		attack_cooldown = true
		await get_tree().create_timer(0.05).timeout
		if current_target == null:
			attack_cooldown = false
			return
		
		#PROJECTILE
		var ins: CharacterBody3D = PROJECTILE.instantiate()
		SignalManager.camera_shake.emit(0.1)
		
		#set projectile stats
		ins.initialize(self, getTeam(), getDamage(), getDamageType(), 0.02, target_position)
		
		get_tree().root.add_child(ins)
		ins.global_position = barrel_pos.global_position
		await get_tree().create_timer(0.05).timeout
		var dir: Vector3 = (target_position - global_position).normalized()
		dir.y += 5
		dir = dir.normalized()
		ins.velocity = dir * 40
		
		#CASING
		var ins1 = CASING.instantiate()
		
		get_tree().root.add_child(ins1)
		
		ins1.global_position = casing_ejectionport.global_position
		ins1.look_at(target_position)
		
		ins1.apply_impulse(Vector3(-2,5,0), Vector3(0.1,0,0))
		#ins2.apply_torque_impulse(Vector3(0,0,5))
		
		animation_player_barrel.play("shoot")
		
		await get_tree().create_timer(0.1).timeout
		
		var a = attack_speed - 0.15
		await get_tree().create_timer(clamp(a, 0, 9999999)).timeout
		
		attack_cooldown = false
