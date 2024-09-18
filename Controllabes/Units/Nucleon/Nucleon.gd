extends "res://Controllabes/Units/Unit.gd"

@onready var bullet_spawn_pos: Node3D = $Base/TurretBase/Turret/Barrel/barrelpos

@onready var turret: MeshInstance3D = $Base/TurretBase/Turret
@onready var barrel: MeshInstance3D = $Base/TurretBase/Turret/Barrel

@onready var default_turret_rot_pos: Node3D = $DefaultTurretPos

@onready var shoot: AnimationPlayer = $Shoot

const SMALL_ENERGY_PROJECTILE = preload("res://Controllabes/Units/SmallEnergyProjectile.tscn")

var on_cooldown: bool

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if !getDetectedTargets().is_empty():
		if getCurrentTarget() != null:
			smoothTurn(Vector3(getTargetPosition().x, turret.global_position.y, getTargetPosition().z), turret, 0.1)
			smoothTurn(getTargetPosition(), barrel, 0.1)
			barrel.rotation.y = 0
		else :
			var trgt = getDetectedTargets()[0]
			smoothTurn(Vector3(trgt.global_position.x, turret.global_position.y, trgt.global_position.z), turret, 0.1)
			smoothTurn(getTargetPosition(), barrel, 0.1)
			barrel.rotation.y = 0
	else:
		smoothTurn(default_turret_rot_pos.global_position, turret, 0.1)
		smoothTurn(default_turret_rot_pos.global_position, barrel, 0.1)

func attack(_unit: CharacterBody3D) -> void:
	if !on_cooldown:
		on_cooldown = true
		shoot.play("Shoot")
		var ins = SMALL_ENERGY_PROJECTILE.instantiate()
		get_tree().root.add_child(ins)
		ins.global_position = bullet_spawn_pos.global_position
		
		#set projectile stats
		ins.initialize(self, getTeam(), getDamage(), getDamageType(), 0.01)
		ins.look_dir = current_target.global_position
		ins.velocity = (current_target.global_position - bullet_spawn_pos.global_position).normalized() * 20
		
		await get_tree().create_timer(attack_speed).timeout
		
		on_cooldown = false
