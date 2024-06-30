extends "res://Controllabes/Structures/StructureWeapon.gd"

@onready var turn_table: MeshInstance3D = $Base/TurnTable
@onready var barrel_base: MeshInstance3D = $Base/TurnTable/Turret/BarrelBase
@onready var bullet_spawn_pos: Node3D = $Base/TurnTable/Turret/BarrelBase/Barrel/Bulletspawnpos
@onready var particles: Node3D = $Base/TurnTable/Turret/BarrelBase/Barrel/Particles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SMALL_PROJECTILE = preload("res://Controllabes/Units/SmallProjectile.tscn")

var on_cooldown: bool

func _physics_process(delta: float) -> void:
	super._process(delta)
	turnTurret()

func turnTurret() -> void:
	if getTarget() != null:
		#turntable
		smoothTurn(Vector3(getTargetPosition().x, turn_table.global_position.y, getTargetPosition().z), turn_table, 0.05)
		#barrel
		smoothTurn(Vector3(barrel_base.global_position.x, getTargetPosition().y, barrel_base.global_position.z), barrel_base, 0.05)

func attack() -> void:
	if !on_cooldown:
		on_cooldown = true
		var ins = SMALL_PROJECTILE.instantiate()
		get_tree().root.add_child(ins)
		ins.global_position = bullet_spawn_pos.global_position
		
		#set projectile stats
		ins.initialize(self, getTeam(), getDamage(), getDamageType(), 0.01)
		ins.look_dir = getTargetPosition()
		ins.velocity = (getTargetPosition() - bullet_spawn_pos.global_position).normalized() * 40
		
		#start particles and animation
		animation_player.play("Shoot")
		for i in particles.get_children():
			i.emitting = true
		
		await get_tree().create_timer(attack_speed).timeout
		
		on_cooldown = false
