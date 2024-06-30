extends Node

class_name AISlave

enum {ATTACK_STRUCTURE, ATTACK_AREA, PATROL_POINTS, PARTROL_AREA}

var max_distance_from_center_point: float = 20.0

var mission_type: int
var can_retreat: bool

var units: Array[CharacterBody3D] = []
var master: Node

var target_position: Vector3
var target: CharacterBody3D

var center_point: Vector3

var regroup_units: bool
var regrouping: bool
var regroup_done: bool

func initialize(type: int, unit_group: Array[CharacterBody3D], can_retreat_: bool, master_: Node, target_: CharacterBody3D = null, target_position_: Vector3 = Vector3.ZERO) -> void:
	mission_type = type
	units = unit_group
	can_retreat = can_retreat_
	master = master_
	
	#optional 
	target = target_
	target_position = target_position_

func _ready() -> void:
	calculateCenterPoint()
	issueCommand(mission_type, target_position, target)

#every 0.5 seconds
func update() -> void:
	calculateCenterPoint()
	
	#check if units need to regroup
	for unit in units:
		if is_instance_valid(unit) and unit.global_position.distance_to(center_point) > max_distance_from_center_point:
			regroup_units = true
			break
	
	#make units regroup
	if regroup_units:
		regroup_units = false
		issueCommand(ATTACK_AREA, center_point)
		regrouping = true
	
	#check if they have regrouped
	if regrouping:
		regrouping = false
		regroup_done = true
		for unit in units:
			if is_instance_valid(unit):
				#unit still too far off centerpoint, continue to regroup
				if unit.global_position.distance_to(center_point) > max_distance_from_center_point / 2:
					regrouping = true
					regroup_done = false
					break
	
	#continue towards mission target
	if !regrouping and regroup_done:
		regroup_done = false
		issueCommand(mission_type, target_position, target)
	
	#target destroyed
	if mission_type == ATTACK_STRUCTURE and target == null:
		returnToMaster()

func returnToMaster() -> void:
	
	#return units to ai master
	for unit in units:
		if is_instance_valid(unit):
			unit.setTargetPosition(unit.global_position)
			unit.setSavedTargetPosition(unit.global_position)
			unit.setAttackMoving(false)
			unit.setState(0)
			master.getUnits().append(unit)
	
	#delete self
	queue_free()

func calculateCenterPoint() -> void:
	var x := 0.0
	var z := 0.0
	
	for unit in units:
		if is_instance_valid(unit):
			x += unit.global_position.x
			z += unit.global_position.z
		
	x = x / units.size()
	z = z / units.size()
	
	center_point = Vector3(x,0,z)

func issueCommand(type: int, target_position_: Vector3 = Vector3.ZERO, target_: CharacterBody3D = null) -> void:
	for unit in units:
		if is_instance_valid(unit):
			match type:
				ATTACK_STRUCTURE:
						unit.setTargetPosition(target_.global_position)
						unit.setSavedTargetPosition(target_.global_position)
						unit.setAttackMoving(true)
						unit.setState(2)
				ATTACK_AREA:
						unit.setTargetPosition(target_position_)
						unit.setSavedTargetPosition(target_position_)
						unit.setAttackMoving(true)
						unit.setState(2)
				PATROL_POINTS:
						pass	#TODO
				PARTROL_AREA:
						pass	#TODO
