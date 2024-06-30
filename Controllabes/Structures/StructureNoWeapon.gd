extends "res://Controllabes/Controllable.gd"

@export var production_building: bool

var spawn_node: Node3D

func _ready() -> void:
	super._ready()
	if production_building:
		spawn_node = get_node("SpawnNode")
	
	if !PlayerVars.getBuildings().has(getName()):
		PlayerVars.getBuildings().append(getName())

func getSpawnNode() -> Node3D: return spawn_node
func setSpawnNode(i: Node3D) -> void: spawn_node = i

func tree_exiting() -> void:
	if PlayerVars.getBuildings().has(getName()):
		PlayerVars.getBuildings().erase(getName())
