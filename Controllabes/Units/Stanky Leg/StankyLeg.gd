extends "res://Controllabes/Units/Unit.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var attack_cooldown: bool

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if getState() != 0 and velocity.distance_to(Vector3.ZERO) > 0.01 and !attack_cooldown:
		animation_player.play("StankyWalk")
	
	elif !attack_cooldown:
		animation_player.pause()

func attack(unit: CharacterBody3D) -> void:
	if !attack_cooldown:
		attack_cooldown = true
		
		unit.reduceHealth(damage, damage_type, self)
		
		animation_player.play("StankyAttack")
		
		await get_tree().create_timer(attack_speed).timeout
		attack_cooldown = false
