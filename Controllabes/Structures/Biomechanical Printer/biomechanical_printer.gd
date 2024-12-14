extends "res://Controllabes/Structures/StructureNoWeapon.gd"

func _ready() -> void:
	super._ready()
	GeneralVars.getTeamVarList(getTeam()).setBioMechanicalPrinterBuilding(self)

func die() -> void:
	GeneralVars.getTeamVarList(getTeam()).setBioMechanicalPrinterBuilding(null)
	super.die()
