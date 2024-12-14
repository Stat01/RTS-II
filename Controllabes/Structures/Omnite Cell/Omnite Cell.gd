extends "res://Controllabes/Structures/StructureNoWeapon.gd"


func _ready() -> void:
	super._ready()
	GeneralVars.getTeamVarList(getTeam()).changeMaxEnergyUsage(500)

func die() -> void:
	GeneralVars.getTeamVarList(getTeam()).changeMaxEnergyUsage(-500)
	super.die()
