extends "res://Controllabes/Structures/StructureNoWeapon.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	GeneralVars.getTeamVarList(getTeam()).setFactoryBuilding(self)
	animation_player.play("Rise")

func die() -> void:
	super.die()
	GeneralVars.getTeamVarList(getTeam()).setFactoryBuilding(null)
