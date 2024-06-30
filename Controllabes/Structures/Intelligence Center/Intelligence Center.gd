extends "res://Controllabes/Structures/StructureNoWeapon.gd"

func _ready() -> void:
	super._ready()
	PlayerVars.setHasRadar(true)

func die() -> void:
	PlayerVars.setHasRadar(false)
	super.die()
