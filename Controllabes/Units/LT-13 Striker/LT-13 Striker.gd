extends "res://Controllabes/Units/Unit.gd"

@onready var animation_tracks: AnimationPlayer = $"Animation Tracks"
@onready var animation_barrels: AnimationPlayer = $"Animation Barrels"

@onready var bullet_spawn_pos: Node3D = $"Base/Turntable/Turret Base/Turret/Bullet Spawn pos"
@onready var casing_ejection_pos: Node3D = $"Base/Turntable/Turret Base/Turret/Casing Ejection pos"

@onready var turret_base: MeshInstance3D = $"Base/Turntable/Turret Base"
@onready var turret: MeshInstance3D = $"Base/Turntable/Turret Base/Turret"
@onready var default_turret_rot_pos: Node3D = $"Default Turret Rot pos"

const SMALL_PROJECTILE = preload("res://Controllabes/Units/SmallProjectile.tscn")
const GATLING_TANK_CASING = preload("res://Controllabes/Units/LT-13 Striker/LT-13 Striker Casing.tscn")

var on_cooldown: bool

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if getState() != 0:
		animation_tracks.play("move")
	else:
		animation_tracks.stop()
	
	if !getDetectedTargets().is_empty():
		if getCurrentTarget() != null:
			smoothTurn(Vector3(getTargetPosition().x, global_position.y, getTargetPosition().z), turret_base, 0.1)
			smoothTurn(getTargetPosition(), turret, 0.1)
			turret.rotation.y = 0
		else :
			var trgt = getDetectedTargets()[0]
			smoothTurn(Vector3(trgt.global_position.x, global_position.y, trgt.global_position.z), turret_base, 0.1)
			smoothTurn(trgt.global_position, turret, 0.1)
			turret.rotation.y = 0
	else:
		smoothTurn(default_turret_rot_pos.global_position, turret_base, 0.1)
		smoothTurn(default_turret_rot_pos.global_position, turret, 0.1)

func attack(_unit: CharacterBody3D) -> void:
	if !on_cooldown:
		on_cooldown = true
		animation_barrels.play("spin")
		var ins = SMALL_PROJECTILE.instantiate()
		get_tree().root.add_child(ins)
		ins.global_position = bullet_spawn_pos.global_position
		
		#set projectile stats
		ins.initialize(self, getTeam(), getDamage(), getDamageType(), 0.01)
		ins.look_dir = current_target.global_position
		ins.velocity = (current_target.global_position - bullet_spawn_pos.global_position).normalized() * 20
		
		#Casing
		var ins1 = GATLING_TANK_CASING.instantiate()
		get_tree().root.add_child(ins1)
		ins1.apply_impulse((casing_ejection_pos.global_position - turret.global_position) * 50, Vector3.ZERO)
		ins1.global_position = casing_ejection_pos.global_position
		ins1.look_at(target_position)
		
		await get_tree().create_timer(attack_speed).timeout
		
		on_cooldown = false
