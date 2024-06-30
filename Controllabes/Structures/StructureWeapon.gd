extends "res://Controllabes/Controllable.gd"

var target: CharacterBody3D
var target_position: Vector3
var detection_area: Area3D
var detected_targets: Array[CharacterBody3D]


func _ready() -> void:
	super._ready()
	
	detection_area = Area3D.new()
	var shape = CollisionShape3D.new()
	shape.shape = CylinderShape3D.new()
	add_child(detection_area)
	detection_area.add_child(shape)
	detection_area.collision_mask = 12
	detection_area.collision_layer = 0
	detection_area.get_child(0).shape.radius = detection_range
	detection_area.get_child(0).shape.height = 10
	detection_area.body_entered.connect(detectionAreaEntered)
	detection_area.body_exited.connect(detectionAreaExited)

func _process(delta: float) -> void:
	super._process(delta)
	
	if !getDetectedTargets().is_empty() and target == null:
		setTarget(getDetectedTargets()[0])
	
	if target != null:
		target_position = target.global_position
		attack()

func detectionAreaEntered(body: Node3D) -> void:
	#check if body is a enemy
	if body is CharacterBody3D and body.has_method("getTeam") and body.getTeam() != getTeam() and body.getTeam() != 0:
		detected_targets.append(body)

func detectionAreaExited(body: Node3D) -> void:
	#check if body is a enemy
	if body is CharacterBody3D and body.has_method("getTeam") and body.getTeam() != getTeam() and body.getTeam() != 0:
		detected_targets.erase(body)
		if target == body:
			target = null

func attack() -> void:
	print_debug("Should Override")

func reduceHealth(damage_: int, damage_type_: int, origin_: CharacterBody3D) -> bool:
	return super.reduceHealth(damage_, damage_type_, origin_)

func setTarget(i: CharacterBody3D) -> void: target = i
func getTarget() -> CharacterBody3D: return target
func setTargetPosition(i: Vector3) -> void: target_position = i
func getTargetPosition() -> Vector3: return target_position
func addToDetectedTarget(unit: CharacterBody3D) -> void: detected_targets.append(unit)
func RemoveFromDetectedTarget(unit: CharacterBody3D) -> void: detected_targets.erase(unit)
func setDetectedTargets(i: Array[CharacterBody3D]) -> void: 
	detected_targets.clear()
	detected_targets.append_array(i)
func getDetectedTargets() -> Array[CharacterBody3D]: return detected_targets
func clearDetectedTargets() -> void: detected_targets.clear()
