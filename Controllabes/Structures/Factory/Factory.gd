extends "res://Controllabes/Structures/StructureNoWeapon.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	PlayerVars.setFactoryBuilding(self)
	animation_player.play("Rise")

func die() -> void:
	super.die()
	PlayerVars.setFactoryBuilding(null)
