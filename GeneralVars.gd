extends Node

var nav_mesh: NavigationRegion3D
var structure_list: Node
var units_list: Node
var current_cursor_type: int
var map_size: int
var paused: bool
var team_vars_list: Array[TeamVars]

const TEAMVARS = preload("res://TeamVars.tscn")
#always one extra because of neutral team
var players: int = 3

func getNavMesh() -> NavigationRegion3D: return nav_mesh
func setNavMesh(i: NavigationRegion3D) -> void: nav_mesh = i
func getStructureList() -> Node: return structure_list
func setStructureList(i: Node) -> void: structure_list = i
func getUnitsList() -> Node: return units_list
func setUnitsList(i: Node) -> void: units_list = i
func setMapSize(i: int) -> void: map_size = i
func getMapSize() -> int: return map_size
func getPaused() -> bool: return paused
func setPaused(i: bool) -> void: paused = i
func getTeamVarList(i: int) -> TeamVars: return team_vars_list[i]

func _ready() -> void:
	for i in players:
		var ins = TEAMVARS.instantiate()
		team_vars_list.append(ins)
