extends "res://Controllabes/Structures/StructureNoWeapon.gd"

func _ready() -> void:
	super._ready()
	GeneralVars.getTeamVarList(getTeam()).changeMaxEnergyUsage(100)

func _process(delta: float) -> void:
	super._process(delta)

func die() -> void:
	GeneralVars.getTeamVarList(getTeam()).changeMaxEnergyUsage(-100)
	super.die()
