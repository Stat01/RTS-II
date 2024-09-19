extends "res://Controllabes/Structures/StructureNoWeapon.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	GeneralVars.getTeamVarList(getTeam()).setVehicleDepotBuilding(self)
	animation_player.play("Rise")

func die() -> void:
	GeneralVars.getTeamVarList(getTeam()).setVehicleDepotBuilding(null)
	super.die()
