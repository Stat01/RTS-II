extends Area3D

var team: int

var check_for_omnite_patches: bool

var terrain_check: Area3D

var should_block: bool

func _ready() -> void:
	terrain_check = get_parent().get_node("Terraincheck")

func _physics_process(_delta: float) -> void:
	if !check_for_omnite_patches:
		if get_overlapping_bodies().is_empty():
			GeneralVars.getTeamVarList(getTeam()).setBuildingBlocked(false)
		else:
			GeneralVars.getTeamVarList(getTeam()).setBuildingBlocked(true)
		
		if !terrain_check.has_overlapping_bodies():
			GeneralVars.getTeamVarList(getTeam()).setBuildingBlocked(true)
	
	else:
		should_block = false
		GeneralVars.getTeamVarList(getTeam()).setBuildingBlocked(true)
		if !get_overlapping_bodies().is_empty():
			for i in get_overlapping_bodies():
				if !i.is_in_group("Omnite"):
					should_block = true
		else:
			should_block = true
		
		if !should_block:
			GeneralVars.getTeamVarList(getTeam()).setBuildingBlocked(false)

func getTeam() -> int: return team
