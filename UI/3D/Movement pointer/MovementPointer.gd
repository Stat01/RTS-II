extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var point_owner: CharacterBody3D

func initialize(point_owner_: CharacterBody3D) -> void:
	point_owner = point_owner_

func _process(_delta: float) -> void:
	if point_owner == null:
		queue_free()
		return
		
	if point_owner.getIsSelected():
		visible = true
	else:
		visible = false

func movePointer(pos: Vector3) -> void:
	global_position = pos
	animation_player.play("Point")
	await animation_player.animation_finished
	animation_player.play("Bob")
