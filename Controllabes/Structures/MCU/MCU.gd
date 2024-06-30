extends "res://Controllabes/Structures/StructureNoWeapon.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var animation_player_3: AnimationPlayer = $AnimationPlayer3

func _ready() -> void:
	super._ready()
	
	animation_player.play("Base")
	animation_player_2.play("Detail")
	animation_player_3.play("Plate")
	PlayerVars.changeMaxEnergyUsage(150)

func die() -> void:
	PlayerVars.changeMaxEnergyUsage(-150)
	super.die()
