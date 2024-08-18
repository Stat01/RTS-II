extends Node

##############Particle Systems

##Explosions
const EXPLOSION_MEDIUM = preload("res://Effects/Explosions/ExplosionMedium.tscn")
const EXPLOSION_SMALL = preload("res://Effects/Explosions/ExplosionSmall.tscn")

##Impact Explosions
const EXPLOSION_IMPACT_SMALL = preload("res://Effects/Explosions/ExplosionImpactSmall.tscn")


##############Decal Systems
const IMPACT_LARGE = preload("res://Effects/Decals/ImpactsDecals/ImpactLarge.tscn")
const IMPACT_MEDIUM = preload("res://Effects/Decals/ImpactsDecals/ImpactMedium.tscn")
const IMPACT_SMALL = preload("res://Effects/Decals/ImpactsDecals/ImpactSmall.tscn")

func explosionSmall(pos: Vector3) -> void:
	var particle: Node3D = EXPLOSION_SMALL.instantiate()
	var decal: Node3D = IMPACT_SMALL.instantiate()
	addToWorld(particle, pos, Vector3.ZERO, decal)

func explosionMedium(pos: Vector3) -> void:
	var particle: Node3D = EXPLOSION_MEDIUM.instantiate()
	var decal: Node3D = IMPACT_MEDIUM.instantiate()
	addToWorld(particle, pos, Vector3.ZERO, decal)

func explosionImpactSmall(pos: Vector3, rot: Vector3) -> void:
	var particle = EXPLOSION_IMPACT_SMALL.instantiate()
	addToWorld(particle, pos, rot)

func addToWorld(particle: Node3D, pos: Vector3, rot: Vector3 = Vector3.ZERO, decal: Node3D = null) -> void:
	get_tree().root.add_child(particle)
	particle.global_position = pos
	particle.global_rotation = rot
	
	if decal != null:
		get_tree().root.add_child(decal)
		decal.global_position = pos
