extends Node

var building_squares: Array[PackedScene] = [
preload("res://UI/3D/Building Squares/1x1.tscn"),
preload("res://UI/3D/Building Squares/2x2.tscn"),
preload("res://UI/3D/Building Squares/3x3.tscn"),
preload("res://UI/3D/Building Squares/4x4.tscn"),
preload("res://UI/3D/Building Squares/2x2 Vehicle Depot.tscn"),
preload("res://UI/3D/Building Squares/3x3 Factory.tscn")
]

var active_building_square: Node3D

const MATERIAL_BLOCK = preload("res://UI/3D/Building Squares/MaterialBlock.tres")
const MATERIAL_PASS = preload("res://UI/3D/Building Squares/MaterialPass.tres")

var ins: Node3D
var once: bool
var once1: bool
var nono_clickerino: bool
var mouse_world_pos

@export var team: int

@onready var camera_controller: Node3D = $"../CameraController"

func _process(_delta: float) -> void:
	if GeneralVars.getTeamVarList(getTeam()).getBuildingMode():
		
		if nono_clickerino:
			ins = GeneralVars.getTeamVarList(getTeam()).getActiveBuilding().instantiate()
			
			if !once:
				once = true
				active_building_square = building_squares[ins.getSize()].instantiate()
				active_building_square.get_child(0).get_child(0).team = getTeam()
				
				if ins.getName() == "Mining Rig":
					active_building_square.get_child(0).get_child(0).check_for_omnite_patches = true
			
			if camera_controller.getWorldClickPosition().has("position"):
				mouse_world_pos = Vector3(camera_controller.getWorldClickPosition()["position"].x, 0, camera_controller.getWorldClickPosition()["position"].z)
			
			if active_building_square != null and mouse_world_pos != null:
				
				if !once1:
					once1 = true
					get_tree().root.get_node("Main").get_node("BuildingSquare").add_child(active_building_square)
				
				active_building_square.global_position = mouse_world_pos
				active_building_square.global_position.x = snapped(active_building_square.global_position.x, 1)
				active_building_square.global_position.z = snapped(active_building_square.global_position.z, 1)
				#active_building_square.global_rotation_degrees.y = 45
				
				if GeneralVars.getTeamVarList(getTeam()).getBuildingBlocked():
					active_building_square.get_child(0).set("surface_material_override/0", MATERIAL_BLOCK)
				else:
					active_building_square.get_child(0).set("surface_material_override/0", MATERIAL_PASS)
				
				#Placing Building
				if Input.is_action_just_pressed("left_click") and !GeneralVars.getTeamVarList(getTeam()).getBuildingBlocked():
					var ins1: Controllable = GeneralVars.getTeamVarList(getTeam()).getActiveBuilding().instantiate()
					get_tree().root.get_node("Main").get_node("Structures").add_child(ins1)
					ins1.global_position = mouse_world_pos
					ins1.global_position.x = snapped(ins1.global_position.x, 1)
					ins1.global_position.z = snapped(ins1.global_position.z, 1)
					DisableBuildingMode(false)
				
				#Turn off build mode
			if Input.is_action_just_pressed("right_click"):
				DisableBuildingMode(true)
		
		if Input.is_action_just_pressed("left_click") and !nono_clickerino:
			nono_clickerino = true

func DisableBuildingMode(refund_building: bool) -> void:
	var ins1 = GeneralVars.getTeamVarList(getTeam()).getActiveBuilding().instantiate()
	GeneralVars.getTeamVarList(getTeam()).setBuildingMode(false)
	GeneralVars.getTeamVarList(getTeam()).setActiveBuilding(null)
	if refund_building:
		SignalManager.refund_building.emit(ins1.getName())
	else:
		SignalManager.building_placed.emit(ins1.getName())
	
	if get_tree().root.get_node("Main").get_node("BuildingSquare").get_child(0) != null:
		get_tree().root.get_node("Main").get_node("BuildingSquare").get_child(0).queue_free()
	
	once = false
	once1 = false
	await get_tree().create_timer(0.05).timeout
	nono_clickerino = false

func getTeam() -> int: return team
