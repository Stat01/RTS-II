extends "res://Controllabes/Controllable.gd"

@onready var plane_1: MeshInstance3D = $Plane
@onready var plane_2: MeshInstance3D = $Plane_001
@onready var plane_3: MeshInstance3D = $Plane_002
@onready var plane_4: MeshInstance3D = $Plane_003
@onready var plane_5: MeshInstance3D = $Plane_004


var state: int = 5

var amount: int = randi_range(50, 1000)
var prev_amount: int = amount

func _ready() -> void:
	super._ready()
	checkAmount()
	global_rotation.y = randi_range(0, 359)

func _process(delta: float) -> void:
	super._process(delta)
	if prev_amount != amount:
		checkAmount()
		updateMesh()
		prev_amount = amount
	


func checkAmount() -> void:
	if amount > 900:
		state = 5
	elif amount > 700:
		state = 4
	elif amount > 500:
		state = 3
	elif amount > 300:
		state = 2
	elif amount > 100:
		state = 1
	else:
		queue_free()

func updateMesh() -> void:
	match state:
		1:
			hideAll()
			plane_1.visible = true
		2:
			hideAll()
			plane_1.visible = true
			plane_2.visible = true
		3:	
			hideAll()
			plane_1.visible = true
			plane_2.visible = true
			plane_3.visible = true
		4:	
			hideAll()
			plane_1.visible = true
			plane_2.visible = true
			plane_3.visible = true
			plane_4.visible = true
		5:	
			plane_1.visible = true
			plane_2.visible = true
			plane_3.visible = true
			plane_4.visible = true
			plane_5.visible = true

func hideAll() -> void:
	plane_1.visible = false
	plane_2.visible = false
	plane_3.visible = false
	plane_4.visible = false
	plane_5.visible = false
	
