extends AnimationPlayer

var root: CharacterBody3D

@export var idle_speed: float = 1
@export var walk_speed: float = 1
@export var attack_speed: float = 1

func _ready() -> void:
	root = get_parent()

func _physics_process(_delta: float) -> void:
	animationHandler()

func animationHandler() -> void:
	if root.can_move == false and root.attack_cooldown == false:
		if get_speed_scale() != idle_speed:
			set_speed_scale(idle_speed)
		if get_current_animation() != "Idle":
			play("Idle")
	
	elif root.attack_cooldown == false:
		if get_speed_scale() != walk_speed:
			set_speed_scale(walk_speed)
		if get_current_animation() != "Walk":
			play("Walk")
