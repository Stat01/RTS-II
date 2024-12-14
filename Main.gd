extends Node3D

@onready var nav_mesh: NavigationRegion3D = $NavigationRegion3D
@onready var structures_list: Node = %Structures
@onready var units_list: Node = %Units

func _ready() -> void:
	GeneralVars.nav_mesh = nav_mesh
	SignalManager.rebake_nav_mesh.connect(reBake)
	GeneralVars.structure_list = structures_list
	GeneralVars.units_list = units_list
##Deprecated 
func reBake() -> void:
	await get_tree().create_timer(0.1).timeout
	nav_mesh.bake_navigation_mesh(true)

func _on_pathing_timer_timeout() -> void:
	SignalManager.update_pathing.emit()
