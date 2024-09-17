extends CharacterBody3D

@export var radius: float

@onready var collision_sphere_3d: GPUParticlesCollisionSphere3D = $GPUParticlesCollisionSphere3D

var sight_area: Area3D

func _ready() -> void:
	collision_sphere_3d.radius = radius
	
	sight_area = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = CylinderShape3D.new()
	add_child(sight_area)
	sight_area.add_child(shape)
	sight_area.collision_mask = 28
	sight_area.collision_layer = 0
	sight_area.get_child(0).shape.radius = radius
	sight_area.get_child(0).shape.height = 10
	sight_area.body_entered.connect(sightAreaEntered)
	sight_area.area_entered.connect(sightAreaEntered)
	sight_area.body_exited.connect(sightAreaExited)
	sight_area.area_exited.connect(sightAreaExited)

func sightAreaEntered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("getTeam") and body.getTeam() != 1:
		body.appendVisibleBy(self)
		
func sightAreaExited(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("getTeam") and body.getTeam() != 1:
		body.eraseVisibleBy(self)
