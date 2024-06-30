extends "res://Controllabes/Units/Unit.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if getState() != 0 and velocity.distance_to(Vector3.ZERO) > 0.01:
		animation_player.play("Walk")
	
	else:
		animation_player.play("Idle")
