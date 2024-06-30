extends "res://Controllabes/Units/Unit.gd"

@onready var turret_base: MeshInstance3D = $Base/Turret

@onready var barrels: MeshInstance3D = $Base/Turret/Barrels

@onready var casing_ejectionport: Node3D = $Base/Turret/CasingEjectionport

@onready var barrel_1_pos: Node3D = $Base/Turret/Barrels/Barrel1pos
@onready var barrel_2_pos: Node3D = $Base/Turret/Barrels/Barrel2pos

@onready var default_turret_rot_pos: Node3D = $DefaultTurretPos
@onready var barrel_dir: Node3D = $Base/Turret/Barrel_dir

@onready var animation_player_barrels: AnimationPlayer = $AnimationPlayerBarrels

@onready var animation_player_tracks: AnimationPlayer = $AnimationPlayerTracks

const PROJECTILE = preload("res://Controllabes/Units/SmallProjectile.tscn")
const CASING = preload("res://Controllabes/Units/AT-12 Gladiator/Casing.tscn")

var attack_cooldown: bool

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	turnTurret()
	
	if getState() != 0:
		animation_player_tracks.play("Tracks")

#why dis exist?
#func smoothTurn(look_pos: Vector3, target_node: Node, rot_speed: float) -> void:
#	if getState() != ATTACKMOVE or global_position.distance_to(target_position) > attack_range:
#		print("turniong")
#		super.smoothTurn(look_pos, target_node, rot_speed)

func turnTurret() -> void:
	if !getDetectedTargets().is_empty():
		if getCurrentTarget() != null:
			smoothTurn(Vector3(getTargetPosition().x, turret_base.global_position.y, getTargetPosition().z), turret_base, 0.1)
			smoothTurn(getTargetPosition(), barrels, 0.1)
			barrels.rotation.y = 0
		else :
			var trgt = getDetectedTargets()[0]
			smoothTurn(Vector3(trgt.global_position.x, turret_base.global_position.y, trgt.global_position.z), turret_base, 0.1)
			smoothTurn(trgt.global_position, barrels, 0.1)
			barrels.rotation.y = 0
	else:
		smoothTurn(default_turret_rot_pos.global_position, turret_base, 0.05)
		smoothTurn(barrel_dir.global_position, barrels, 0.05)

func attack(_unit: CharacterBody3D) -> void:
	if !attack_cooldown:
		attack_cooldown = true
		await get_tree().create_timer(0.05).timeout
		if current_target == null:
			attack_cooldown = false
			return
		
		#PROJECTILE 1
		var ins: CharacterBody3D = PROJECTILE.instantiate()
		
		#set projectile stats
		ins.initialize(self, getTeam(), getDamage(), getDamageType(), 0.02)
		
		get_tree().root.add_child(ins)
		ins.global_position = barrel_1_pos.global_position
		ins.look_dir = target_position
		ins.velocity = (target_position - barrel_1_pos.global_position).normalized() * 40
		
		#PROJECTILE 2
		var ins1: CharacterBody3D = PROJECTILE.instantiate()
		
		#set projectile stats
		ins1.initialize(self, getTeam(), getDamage(), getDamageType(), 0.02)
		
		get_tree().root.add_child(ins1)
		ins1.global_position = barrel_2_pos.global_position
		ins1.look_dir = target_position
		ins1.velocity = (target_position - barrel_2_pos.global_position).normalized() * 40
		
		#CASING 1
		var ins2 = CASING.instantiate()
		
		get_tree().root.add_child(ins2)
		
		ins2.global_position = casing_ejectionport.global_position
		ins2.look_at(target_position)
		
		ins2.apply_impulse(Vector3(-2,5,0), Vector3(0.1,0,0))
		#ins2.apply_torque_impulse(Vector3(0,0,5))
		
		animation_player_barrels.play("Shoot")
		
		await get_tree().create_timer(0.1).timeout
		
		#CASING 2
		var ins3 = CASING.instantiate()
		
		get_tree().root.add_child(ins3)
		
		ins3.global_position = casing_ejectionport.global_position
		ins3.look_at(target_position)
		
		ins3.apply_impulse(Vector3(-2,5,0), Vector3(0.1,0,0))
		#ins3.apply_torque_impulse(Vector3(0,0,5))
		
		var a = attack_speed - 0.15
		await get_tree().create_timer(clamp(a, 0, 9999999)).timeout
		
		attack_cooldown = false
