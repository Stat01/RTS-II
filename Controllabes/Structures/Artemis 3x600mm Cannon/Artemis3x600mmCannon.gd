extends "res://Controllabes/Structures/StructureWeapon.gd"

@onready var turret: MeshInstance3D = $TurnTable/Turret
@onready var barrel_base: MeshInstance3D = $TurnTable/Turret/BarrelBase

@onready var barrel_1: MeshInstance3D = $TurnTable/Turret/BarrelBase/Barrel1
@onready var barrel_2: MeshInstance3D = $TurnTable/Turret/BarrelBase/Barrel2
@onready var barrel_3: MeshInstance3D = $TurnTable/Turret/BarrelBase/Barrel3
@onready var animation_barrel_base: AnimationPlayer = $"Animation BarrelBase"

@onready var animation_barrels: AnimationPlayer = $"Animation Barrels"

@onready var flat1: GPUParticles3D = $TurnTable/Turret/BarrelBase/Barrel1/Flat
@onready var forward1: GPUParticles3D = $TurnTable/Turret/BarrelBase/Barrel1/Forward
@onready var flat2: GPUParticles3D = $TurnTable/Turret/BarrelBase/Barrel2/Flat
@onready var forward2: GPUParticles3D = $TurnTable/Turret/BarrelBase/Barrel2/Forward
@onready var flat3: GPUParticles3D = $TurnTable/Turret/BarrelBase/Barrel3/Flat
@onready var forward3: GPUParticles3D = $TurnTable/Turret/BarrelBase/Barrel3/Forward
@onready var dust: GPUParticles3D = $Dust

var active_barrel: int
var cooldown_active: bool

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	animateTurret()

func animateTurret() -> void:
	if getTarget() != null:
		turret.look_at(Vector3(getTargetPosition().x, turret.global_position.y, getTargetPosition().z))
		barrel_base.look_at(Vector3(getTargetPosition().x, getTargetPosition().y * 1.1, getTargetPosition().z))

func attack() -> void:
	if !cooldown_active and getTarget() != null:
		
		if active_barrel >= 3:
			active_barrel = 1
		else:
			active_barrel += 1
		
		animateBarrels(active_barrel)
		
		cooldown_active = true
		await get_tree().create_timer(attack_speed).timeout
		cooldown_active = false

func animateBarrels(barrel: int) -> void:
		match barrel:
			1:
				animation_barrels.play("1")
				flat1.set_emitting(true)
				forward1.set_emitting(true)
			2:
				animation_barrels.play("2")
				flat2.set_emitting(true)
				forward2.set_emitting(true)
			3:
				animation_barrels.play("3")
				flat3.set_emitting(true)
				forward3.set_emitting(true)
		
		animation_barrel_base.play("recoildamp")
		dust.set_emitting(true)
		
		SignalManager.camera_shake.emit(0.1)
