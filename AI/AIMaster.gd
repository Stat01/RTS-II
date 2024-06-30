extends Node

class_name AIMaster

@onready var spawn_timer: Timer = $SpawnEnemyTimer
@onready var launch_attack_timer: Timer = $LaunchAttackTimer

@export var enemy_spawn_interval := 20
@export var min_attack_interval := 60
@export var max_attack_interval := 300

#units
const ZELVA = preload("res://Controllabes/Units/Zel'va/Zel'va.tscn")

const AI_SLAVE = preload("res://AI/AISlave.tscn")

var units: Array[CharacterBody3D]
var slaves: Array[Node]

var enemy_spawn_point: Node3D

func _ready() -> void:
	spawn_timer.start(enemy_spawn_interval)
	enemy_spawn_point = get_tree().root.get_node("Main").get_node("Enemyspawnpoint")

func launchAttack() -> void:
	if !GeneralVars.getStructureList().get_children().is_empty():
		var ins = AI_SLAVE.instantiate()
		var unit_group: Array[CharacterBody3D]
		
		for unit in units:
			unit_group.append(unit)
		
		ins.initialize(0, unit_group, false, self, GeneralVars.getStructureList().get_child(0))
		get_tree().root.get_node("Main").add_child(ins)
		slaves.append(ins)
		units.clear()
		
		print("AI Master launching attack")
	launch_attack_timer.start(randi_range(min_attack_interval, max_attack_interval))

func spawnEnemy() -> void:
	var ins = ZELVA.instantiate()
	GeneralVars.getUnitsList().add_child(ins)
	ins.global_position = enemy_spawn_point.global_position + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	getUnits().append(ins)

func getUnits() -> Array[CharacterBody3D]: return units
