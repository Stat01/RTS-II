extends "res://Controllabes/Structures/StructureNoWeapon.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var animation_player_3: AnimationPlayer = $AnimationPlayer3
@onready var animation_player_4: AnimationPlayer = $AnimationPlayer4

func _ready() -> void:
	super._ready()
	animation_player.play("Grate/Grate")
	animation_player_2.play("Ooze/Omnite ooze")
	animation_player_3.play("Plate/Plate")
	animation_player_4.play("Base/Base")
	
	GeneralVars.getTeamVarList(getTeam()).changeMaxOmnite(500)

func die() -> void:
	super.die()
	GeneralVars.getTeamVarList(getTeam()).changeMaxOmnite(-500)
