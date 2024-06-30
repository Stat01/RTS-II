extends "res://Controllabes/Structures/StructureNoWeapon.gd"

@onready var animation_player_crane: AnimationPlayer = $AnimationPlayer
@onready var animation_player_drill: AnimationPlayer = $AnimationPlayer2
@onready var animation_player_piston: AnimationPlayer = $AnimationPlayer3

@onready var omnite_area: Area3D = $"Omnite Area"

@onready var timer: Timer = $Timer

var mining_time: float = 2
var omnite_yield: int

func _ready() -> void:
	super._ready()
	animation_player_crane.play("Crane/Crane")
	animation_player_drill.play("Drill/Drill")
	animation_player_piston.play("Piston/Piston")
	timer.start(mining_time)

func _on_timer_timeout() -> void:
	omnite_yield = omnite_area.get_overlapping_bodies().size()
	
	PlayerVars.changeOmnite(omnite_yield)
	
	if omnite_yield <= 0:
		animation_player_crane.stop()
		animation_player_drill.stop()
		animation_player_piston.stop()
