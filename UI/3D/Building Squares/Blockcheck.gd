extends Area3D

@export var check_for_omnite_patches: bool

var should_block: bool

func _physics_process(delta: float) -> void:
	if !check_for_omnite_patches:
		if get_overlapping_bodies().is_empty():
			PlayerVars.setBuildingBlocked(false)
		else:
			PlayerVars.setBuildingBlocked(true)
	else:
		should_block = false
		PlayerVars.setBuildingBlocked(true)
		if !get_overlapping_bodies().is_empty():
			for i in get_overlapping_bodies():
				if !i.is_in_group("Omnite"):
					should_block = true
		else:
			should_block = true
		
		if !should_block:
			PlayerVars.setBuildingBlocked(false)
