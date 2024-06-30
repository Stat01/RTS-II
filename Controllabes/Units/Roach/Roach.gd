extends "res://Controllabes/Units/Unit.gd"

@onready var animation_player: AnimationPlayer = $"AnimationPlayer"

const DEATH_PARTICLES = preload("res://Controllabes/Units/Roach/DeathParticles.tscn")
const ROACH_DEAD = preload("res://Controllabes/Units/Roach/RoachDead.tscn")

var dying: bool
var attack_cooldown: bool

func _ready() -> void:
	super._ready()
	var ins = NameGenerator.new()
	setName(ins.new_name()[0])
	
	if randi_range(0,1000):
		setName("Rasmus")

func attack(unit: CharacterBody3D) -> void:
	if !attack_cooldown:
		attack_cooldown = true
		
		unit.reduceHealth(damage, damage_type, self)
		
		animation_player.set_speed_scale(0.8)
		animation_player.play("Attack")
		
		await get_tree().create_timer(attack_speed).timeout
		attack_cooldown = false

func die() -> void:
	if !dying:
		dying = true
		set_visible(false)
		
		var ins = DEATH_PARTICLES.instantiate()
		get_tree().root.add_child(ins)
		ins.global_position = global_position
		var ins1 = ROACH_DEAD.instantiate()
		get_tree().root.add_child(ins1)
		ins1.global_position = global_position
		
		super.die()
