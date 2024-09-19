extends "res://Controllabes/Structures/StructureNoWeapon.gd"

func _ready() -> void:
	super._ready()
	GeneralVars.getTeamVarList(getTeam()).setHasRadar(true)

func die() -> void:
	GeneralVars.getTeamVarList(getTeam()).setHasRadar(false)
	super.die()
