extends Unit

@onready var detonate_area: Area3D = $DetonateArea
@onready var detonate_player: AnimationPlayer = $Detonate
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if can_move:
		animation_player.play("Roll")
	else:
		animation_player.pause()

func detonate() -> void:
	detonate_player.play("Detonate")
	await detonate_player.animation_finished
	EffectCreator.explosionMedium(global_position)
	for unit in detonate_area.get_overlapping_bodies():
		if unit is CharacterBody3D and unit.has_method("getTeam") and unit.getTeam() != team and unit.getTeam() != 0:
			unit.reduceHealth(getDamage(), getDamageType(), self)
	queue_free()

func _on_detonate_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("getTeam") and body.getTeam() != team and body.getTeam() != 0:
		detonate()
