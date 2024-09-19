extends TextureButton

@onready var label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var block_rect: TextureRect = $TextureRect

var unit: PackedScene
var is_structure_button: bool

var print_locked: bool

var unit_name: String
var price: int
var build_time: int
var unit_requirements: Array[String]
var amount_in_queue: int
var currently_building: bool
var production_building: int
var building_complete: bool

var is_locked: bool

var ins: Node3D

const EXAMPLE_PORTRAIT = preload("res://UI/2D/Buttons/ExamplePortrait.png")

const LOCKED_ICON = preload("res://UI/2D/UI/Locked_Icon.png")
const UNLOCKED_ICON = preload("res://UI/2D/UI/Unlocked_Icon.png")

func _ready() -> void:
	await get_tree().create_timer(0.05).timeout
	ins = unit.instantiate()
	unit_name = ins.getName()
	price = ins.getPrice()
	build_time = ins.getBuildTime()
	unit_requirements.append_array(ins.getUnlockRequirements())
	production_building = ins.getProductionLocation()
	texture_normal = ins.getIcon()
	if texture_normal == null:
		texture_normal = EXAMPLE_PORTRAIT
	
	SignalManager.refund_building.connect(refundBuilding)
	SignalManager.building_placed.connect(buildingPlaced)

func _process(_delta: float) -> void:
	label.text = unit_name
	if amount_in_queue > 0 and !is_structure_button:
		label.text += "\n" + str(amount_in_queue)
	
	if currently_building or building_complete:
		progress_bar.max_value = timer.wait_time
		progress_bar.value = timer.wait_time - timer.time_left
	else:
		progress_bar.value = 0
	
	for i in unit_requirements:
		if !GeneralVars.getTeamVarList(getTeam()).getBuildings().has(i):
			if print_locked:
				print("should lock")
			is_locked = true
			break
		else:
			if print_locked:
				print("should unlock")
			is_locked = false
	
	if is_locked:
		block_rect.texture = LOCKED_ICON
		tooltip_text = ""
	else:
		block_rect.texture = UNLOCKED_ICON
		tooltip_text = unit_name + "\n" + str(price) + "c"

func _on_gui_input(event: InputEvent) -> void:
	if !is_locked:
		if is_structure_button:
			if event is InputEventMouseButton and event.is_action_pressed("left_click"):
				#start building
				if !currently_building and GeneralVars.getTeamVarList(getTeam()).getOmnite() >= ins.getPrice() and amount_in_queue == 0:
					GeneralVars.getTeamVarList(getTeam()).changeOmnite(-ins.getPrice())
					currently_building = true
					amount_in_queue += 1
					timer.start(build_time)
				
				#place building
				if building_complete:
					GeneralVars.getTeamVarList(getTeam()).setBuildingMode(true)
					GeneralVars.getTeamVarList(getTeam()).setActiveBuilding(unit)
			elif event is InputEventMouseButton and event.is_action_pressed("right_click"):
				refundBuilding(unit_name)
				timer.stop()
		else:
			if event is InputEventMouseButton and event.is_action_pressed("left_click"):
				if GeneralVars.getTeamVarList(getTeam()).getOmnite() >= ins.getPrice():
					currently_building = true
					GeneralVars.getTeamVarList(getTeam()).changeOmnite(-ins.getPrice())
					amount_in_queue += 1
					if amount_in_queue == 1:
						timer.start(build_time)
			
			elif event is InputEventMouseButton and event.is_action_pressed("right_click"):
				if currently_building:
					GeneralVars.getTeamVarList(getTeam()).changeOmnite(ins.getPrice())
					amount_in_queue -= 1
					if amount_in_queue <= 0:
						currently_building = false

func _on_timer_timeout() -> void:
	if is_structure_button:
		building_complete = true
	else:
		var ins1 = unit.instantiate()
		match production_building:
			
			1:	#Vehicle Depot
				if GeneralVars.getTeamVarList(getTeam()).hasVehicleDepotBuilding():
					GeneralVars.getUnitsList().add_child(ins1)
					var pos : Vector3 = GeneralVars.getTeamVarList(getTeam()).getVehicleDepotBuilding().getSpawnNode().global_position
					ins1.global_position = Vector3(pos.x + randf_range(-1, 1), pos.y, pos.z + randf_range(-1, 1))
					await get_tree().create_timer(0.05).timeout
					commandMoveUnit(ins1, GeneralVars.getTeamVarList(getTeam()).getVehicleDepotBuilding().getWayPoint())
			2:	#Factory
				if GeneralVars.getTeamVarList(getTeam()).hasFactoryBuilding():
					GeneralVars.getUnitsList().add_child(ins1)
					var pos : Vector3 = GeneralVars.getTeamVarList(getTeam()).getFactoryBuilding().getSpawnNode().global_position
					ins1.global_position = Vector3(pos.x + randf_range(-1.5, 1.5), pos.y, pos.z + randf_range(-1.5, 1.5))
					await get_tree().create_timer(0.05).timeout
					commandMoveUnit(ins1, GeneralVars.getTeamVarList(getTeam()).getFactoryBuilding().getWayPoint())
		
		amount_in_queue -= 1
		if amount_in_queue > 0:
			timer.start(build_time)
		else:
			currently_building = false

func commandMoveUnit(unit_: Controllable, collision_pos: Vector3) -> void:
	unit_.setTargetPosition(collision_pos)
	unit_.setSavedTargetPosition(collision_pos)
	unit_.getMovementPointer().movePointer(collision_pos)
	unit_.forceSetCurrentTarget(null)
	unit_.setState(1)

func refundBuilding(unit_name_: String) -> void:
	if is_structure_button and unit_name_ == unit_name:
		if building_complete or currently_building:
			GeneralVars.getTeamVarList(getTeam()).changeOmnite(ins.getPrice())
			buildingPlaced(unit_name_)

func buildingPlaced(unit_name_: String) -> void:
	if is_structure_button and unit_name_ == unit_name:
		if building_complete or currently_building:
			building_complete = false
			currently_building = false
			amount_in_queue = 0

func getTeam() -> int: return get_node("../../../../../../../../../").getTeam()
