extends "res://Controllabes/Structures/StructureNoWeapon.gd"

func _ready() -> void:
	super._ready()
	PlayerVars.changeMaxEnergyUsage(100)

func _process(delta: float) -> void:
	super._process(delta)

func die() -> void:
	PlayerVars.changeMaxEnergyUsage(-100)
	super.die()
