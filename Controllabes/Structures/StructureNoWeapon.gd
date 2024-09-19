extends "res://Controllabes/Controllable.gd"

@export var production_building: bool

var spawn_node: Node3D
var waypoint: Vector3

func _ready() -> void:
	super._ready()
	if production_building:
		spawn_node = get_node("SpawnNode")
		waypoint = spawn_node.global_position
	
	if !GeneralVars.getTeamVarList(getTeam()).getBuildings().has(getName()):
		GeneralVars.getTeamVarList(getTeam()).getBuildings().append(getName())
	
	connect("tree_exiting", tree_exiting)

func getSpawnNode() -> Node3D: return spawn_node
func setSpawnNode(i: Node3D) -> void: spawn_node = i
func getWayPoint() -> Vector3: return waypoint
func setWayPoint(i: Vector3) -> void: waypoint = i

func setIsProductionBuilding(i: bool) -> void: production_building = i
func isProductionBuilding() -> bool: return production_building

func tree_exiting() -> void:
	print(self)
	if GeneralVars.getTeamVarList(getTeam()).getBuildings().has(getName()):
		GeneralVars.getTeamVarList(getTeam()).getBuildings().erase(getName())
