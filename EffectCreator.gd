extends Node

#Particle Systems
const EXPLOSION_SMALL = preload("res://Effects/Explosions/Explosion small/Explosion small.tscn")
const EXPLOSION_MEDIUM = preload("res://Effects/Explosions/Explosion small/Explosion medium.tscn")

#Decal Systems
const IMPACT_LARGE = preload("res://Effects/Decals/Impacts/ImpactLarge.tscn")
const IMPACT_MEDIUM = preload("res://Effects/Decals/Impacts/ImpactMedium.tscn")
const IMPACT_SMALL = preload("res://Effects/Decals/Impacts/ImpactSmall.tscn")

func explosionSmall(pos: Vector3) -> void:
	var particle = EXPLOSION_SMALL.instantiate()
	var decal = IMPACT_SMALL.instantiate()
	addToWorld(particle, decal, pos)

func explosionMedium(pos: Vector3) -> void:
	var particle = EXPLOSION_MEDIUM.instantiate()
	var decal = IMPACT_MEDIUM.instantiate()
	addToWorld(particle, decal, pos)

func addToWorld(particle: Node3D, decal: Node3D, pos: Vector3) -> void:
	get_tree().root.add_child(particle)
	get_tree().root.add_child(decal)
	particle.global_position = pos
	decal.global_position = pos
