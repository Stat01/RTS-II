extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var glitch_effect: ColorRect = $CanvasLayer/Glitch
@onready var select_cursor: MeshInstance3D = $Select
@onready var attack_cursor: MeshInstance3D = $Attack

var mouse_pos: Vector2
var mouse_middle_pan_pos: Vector2
var mouse_middle_down: bool = false

var mouse_dragging: bool = false
var pos_1: Vector3 = Vector3.ZERO
var pos_2: Vector3 = Vector3.ZERO
var box: CSGBox3D = CSGBox3D.new()
var box_pos_1: Vector3
var box_pos_2: Vector3
var dragging_box: bool

var target_zoom: float
var pan_direction: Vector2
var panning: bool
var panning_key_amount: int
var key_pan_direction: Vector2

@export var team: int

@export var min_zoom: float
@export var max_zoom: float

#shake
var shake_fade: float = 5.0
var shake_strength: float = 0.0

#commands
var attack_move: bool

var building_mode: bool

#AI debug
const AI_SLAVE = preload("res://AI/AISlave.tscn")
const AI_MASTER = preload("res://AI/AIMaster.tscn")
var ai_master: Node

func _ready() -> void:
	
	SignalManager.minimap_camera_position_changed.connect(minimapMoveCamera)
	SignalManager.camera_shake.connect(shakeCamera)
	target_zoom = global_position.y

	#selection box
	box.material = load("res://UI/3D/selectionboxmaterial.tres")
	
	#AI debug
	ai_master = AI_MASTER.instantiate()

func _physics_process(delta: float) -> void:
	
	#update mouse pos
	mouse_pos = get_viewport().get_mouse_position()
	if !GeneralVars.getPaused():
#region Camera panning
		if panning:
			pan_direction = mouse_pos - mouse_middle_pan_pos
			pan_direction = pan_direction / 64
			pan_direction *= Settings.camera_pan_speed
		
		if panning_key_amount > 0:
			panning_key_amount *= Settings.camera_edge_pan_speed
		
		if Settings.edge_pan:
			##left
			if mouse_pos.x < get_viewport().get_visible_rect().size.x - (get_viewport().get_visible_rect().size.x - 30):
				global_position.x -= 1
			##right
			if mouse_pos.x > get_viewport().get_visible_rect().size.x - 30:
				global_position.x += 1
			##forward
			if mouse_pos.y < get_viewport().get_visible_rect().size.y - (get_viewport().get_visible_rect().size.y - 30):
				global_position.z -= 1
			##backward
			if mouse_pos.y > get_viewport().get_visible_rect().size.y - 30:
				global_position.z += 1
		
		if panning or panning_key_amount > 0:
			global_position += Vector3(pan_direction.x + key_pan_direction.x, 0, pan_direction.y + key_pan_direction.y)
#endregion
	
#region Update zoom level
		global_position.y = lerp(global_position.y, target_zoom, 0.5)
#endregion
	
#region Cursors
		GeneralVars.current_cursor_type = 0
		select_cursor.visible = false
		attack_cursor.visible = false
		var info: Dictionary = getWorldClickPosition()
		if "position" in info:
			
			#3d cursors
			select_cursor.global_position = info["position"]
			attack_cursor.global_position = info["position"]
			
			var collider = info["collider"]
			if collider is CharacterBody3D and collider.has_method("getTeam"):
				match collider.getTeam():
					0:	#Neutral
						GeneralVars.current_cursor_type = 0
					1:	#Friendly
						GeneralVars.current_cursor_type = 1
						select_cursor.visible = true
					2:	#Enemy
						if collider.visible:
							if !GeneralVars.getTeamVarList(getTeam()).getSelectedUnits().is_empty():
								GeneralVars.current_cursor_type = 2
								attack_cursor.visible = true
							else:
								GeneralVars.current_cursor_type = 1
								select_cursor.visible = true
#endregion

#region Camera shake
		if shake_strength > 0:
			shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
			
			var offset: Vector2 = randomOffset()
			camera.h_offset = offset.x
			camera.v_offset = offset.y
			glitch_effect.material.set("shader_parameter/shake_power", shake_strength * 0.01)
			glitch_effect.material.set("shader_parameter/shake_rate", shake_strength * 1.0)
			glitch_effect.material.set("shader_parameter/shake_color", shake_strength * 0.01)
#endregion

func minimapMoveCamera(pos: Vector2) -> void:
	var real_mouse_pos := pos * GeneralVars.getMapSize() * 2
	global_position = Vector3(real_mouse_pos.x - GeneralVars.getMapSize() * 2, global_position.y, real_mouse_pos.y)

func _unhandled_input(event: InputEvent) -> void:
	if !GeneralVars.getPaused():
#region Camera zoom and panning
		if event is InputEventMouseButton:
			match event.button_index:
				#zoom in
				MOUSE_BUTTON_WHEEL_UP: if event.pressed: target_zoom -= 2.5
				#zoom out
				MOUSE_BUTTON_WHEEL_DOWN: if event.pressed: target_zoom += 2.5
				#camera middle mouse pan
				MOUSE_BUTTON_MIDDLE:
					if event.pressed:
						panning = true
						mouse_middle_pan_pos = event.position
					else:
						panning = false
						pan_direction = Vector2.ZERO
		target_zoom = clamp(target_zoom, max_zoom, min_zoom)
		
		##left
		if event.is_action_pressed("camera_left"):
			key_pan_direction.x -= 1
			panning_key_amount += 1
		##right
		if event.is_action_pressed("camera_right"):
			key_pan_direction.x += 1
			panning_key_amount += 1
		##forward
		if event.is_action_pressed("camera_forward"):
			key_pan_direction.y -= 1
			panning_key_amount += 1
		##backward
		if event.is_action_pressed("camera_backward"):
			key_pan_direction.y += 1
			panning_key_amount += 1
		
		if event.is_action_released("camera_left"):
			key_pan_direction.x += 1
			panning_key_amount -= 1
		if event.is_action_released("camera_right"):
			key_pan_direction.x -= 1
			panning_key_amount -= 1
		if event.is_action_released("camera_forward"):
			key_pan_direction.y += 1
			panning_key_amount -= 1
		if event.is_action_released("camera_backward"):
			key_pan_direction.y -= 1
			panning_key_amount -= 1
#endregion
	
#region Selection
	#Single
		if !building_mode:
			if event.is_action_pressed("left_click"):
				if attack_move:
					issueCommand()
					attack_move = false
				else:
					getSelection(Input.is_action_pressed("shift"))
			
			#Drag
			if event.is_action_pressed("left_click"):
				mouse_dragging = true
				startSelectionBox()
			
			if event.is_action_released("left_click") and mouse_dragging:
				mouse_dragging = false
				endSelectionBox()
			
			#Rightclick commands
			if event.is_action_released("right_click"):
					attack_move = false
					issueCommand()
			
			#set attack move
			if event.is_action_pressed("attack_move") and !attack_move:
				attack_move = true
		
		#Deselect button
		if event.is_action_pressed("deselect"):
			for unit: Controllable in GeneralVars.getTeamVarList(getTeam()).getSelectedUnits():
				unit.is_selected = false
			GeneralVars.getTeamVarList(getTeam()).clearSelectedUnits()
#endregion
	
#region Draw box
		if event.is_action_pressed("left_click") and !dragging_box:
			dragging_box = true
			var result = getWorldClickPosition()
			if "position" in result:
				box_pos_1 = result["position"]
		
		if dragging_box:
			var result = getWorldClickPosition()
			if "position" in result:
				box_pos_2 = result["position"]
			
			if box.get_parent() == null:
				get_tree().root.add_child(box)
			
			box.visible = true
			calculateSelectionBoxPos()
			
			
		if event.is_action_released("left_click") and dragging_box:
			dragging_box = false
			box.visible = false
#endregion
	
#region All army hotkey
		elif event.is_action_pressed("select_all_army"):
			for unit: Controllable in GeneralVars.getTeamVarList(getTeam()).getAllUnits():
				if !unit.getIsBuilding():
					unit.setIsSelected(true)
					GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
#endregion
	
#region Debug
		#Delete Controllable, debug
		if event.is_action_pressed("delete"):
			for unit: Controllable in GeneralVars.getTeamVarList(getTeam()).getSelectedUnits():
				unit.die()
		
		elif event.is_action("debugbutton"):
			var result = getWorldClickPosition()
			if "position" in result:
				var spawn_pos: Vector3 = result["position"]
				var ins = load("res://Controllabes/Units/Nucleon/Nucleon.tscn").instantiate()
				GeneralVars.getUnitsList().add_child(ins)
				ins.global_position = spawn_pos
		
		elif event.is_action_pressed("select_all_enemy_army"):
			var amount: int = 0
			for unit in GeneralVars.getUnitsList().get_children():
				if unit is Controllable:
					amount += 1
					if !unit.getIsBuilding() and unit.getTeam() == 2:
						unit.setIsSelected(true)
						GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
			print(amount)
#endregion
	
func calculateSelectionBoxPos() -> void:
	var pos_x: float = (box_pos_1.x + box_pos_2.x) / 2
	var pos_z: float = (box_pos_1.z + box_pos_2.z) / 2
	var size_x: float = absf(box_pos_1.x - box_pos_2.x)
	var size_z: float = absf(box_pos_1.z - box_pos_2.z)
	
	box.global_position = Vector3(pos_x, 0, pos_z)
	box.size = Vector3(size_x, 0.1, size_z)

func shakeCamera(strength: float) -> void:
	applyShake(strength)

func applyShake(strength: float) -> void:
	shake_strength = strength

func randomOffset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func getWorldClickPosition() -> Dictionary:
	var worldspace = get_world_3d().direct_space_state
	var start = camera.project_ray_origin(mouse_pos)
	var end = camera.project_position(mouse_pos, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	return result

func getSelection(shift_pressed: bool) -> void:
	var result = getWorldClickPosition()
	
	if "position" in result:
		var collider = result["collider"]
		
		if !shift_pressed:
			for unit in GeneralVars.getTeamVarList(getTeam()).getSelectedUnits():
				if is_instance_valid(unit):
					unit.setIsSelected(false)
			GeneralVars.getTeamVarList(getTeam()).clearSelectedUnits()
		
		if collider != null and collider is CharacterBody3D and collider.visible:
			var unit: CharacterBody3D = collider
			if shift_pressed and unit.getIsSelected() == true:
				GeneralVars.getTeamVarList(getTeam()).removeFromSelectedUnits(unit)
				unit.setIsSelected(false)
			else:
				GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
				unit.setIsSelected(true)
				# and (collider.is_in_group("Team1") or collider.is_in_group("Team0"))

func startSelectionBox() -> void:
	var result = getWorldClickPosition()
	if "position" in result:
		pos_1 = result["position"]

func endSelectionBox() -> void:
	var result = getWorldClickPosition()
	if "position" in result:
		pos_2 = result["position"]
		
		for unit in GeneralVars.getTeamVarList(getTeam()).getAllUnits():
			if !unit.is_building:
				#start top left
				if pos_1.x < pos_2.x and pos_1.z < pos_2.z:
					if unit.global_position.x > pos_1.x and unit.global_position.x < pos_2.x:
						if unit.global_position.z > pos_1.z and unit.global_position.z < pos_2.z:
							GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
							unit.setIsSelected(true)
				
				#start bottom left
				if pos_1.x < pos_2.x and pos_1.z > pos_2.z:
					if unit.global_position.x > pos_1.x and unit.global_position.x < pos_2.x:
						if unit.global_position.z < pos_1.z and unit.global_position.z > pos_2.z:
							GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
							unit.setIsSelected(true)
				
				#start bottom right
				if pos_1.x > pos_2.x and pos_1.z > pos_2.z:
					if unit.global_position.x < pos_1.x and unit.global_position.x > pos_2.x:
						if unit.global_position.z < pos_1.z and unit.global_position.z > pos_2.z:
							GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
							unit.setIsSelected(true)
				
				#start top right
				if pos_1.x > pos_2.x and pos_1.z < pos_2.z:
					if unit.global_position.x < pos_1.x and unit.global_position.x > pos_2.x:
						if unit.global_position.z > pos_1.z and unit.global_position.z < pos_2.z:
							GeneralVars.getTeamVarList(getTeam()).addToSelectedUnits(unit)
							unit.setIsSelected(true)

func issueCommand() -> void:
	var result = getWorldClickPosition()
	if "collider" in result:
		var collider = result["collider"]
		var collision_pos = result["position"]
		
		for unit in GeneralVars.getTeamVarList(getTeam()).getSelectedUnits():
#region Command Unit
			if !unit.getIsBuilding():
				#attack move check
				if attack_move:
					#unit
					if collider != null and collider is CharacterBody3D:
						#visible
						if !collider.getVisibleBy().is_empty():
							commandAttackUnit(unit, collider, collision_pos)
						#not visible
						else:
							commandAttackMove(unit, collision_pos)
					#no unit
					else:
						commandAttackMove(unit, collision_pos)
				#no attack move
				else:
					#unit
					if collider != null and collider is CharacterBody3D:
						#enemy unit
						if collider.getTeam() == 2:
							#visible
							if !collider.getVisibleBy().is_empty():
								commandAttackUnit(unit, collider, collision_pos)
							#not visible
							else:
								commandMoveUnit(unit, collision_pos)
						else:
							commandMoveToUnit(unit, collider, collision_pos)
					#no unit
					else:	
						commandMoveUnit(unit, collision_pos)
#endregion
#region Command Structure
			elif unit.has_method("getWayPoint") and unit.isProductionBuilding() and !attack_move:
				unit.setWayPoint(collision_pos)
				unit.getMovementPointer().movePointer(collision_pos)
#endregion

func commandAttackUnit(unit: Controllable, collider: Controllable, collision_pos: Vector3) -> void:
	unit.setCurrentTarget(collider)
	unit.setSavedTargetPosition(collision_pos)
	unit.getMovementPointer().movePointer(collision_pos)
	unit.setState(2)

func commandAttackMove(unit: Controllable, collision_pos: Vector3) -> void:
	unit.setTargetPosition(collision_pos)
	unit.setSavedTargetPosition(collision_pos)
	unit.getMovementPointer().movePointer(collision_pos)
	unit.setAttackMoving(true)
	unit.setState(2)

func commandMoveUnit(unit: Controllable, collision_pos: Vector3) -> void:
	unit.setTargetPosition(collision_pos)
	unit.setSavedTargetPosition(collision_pos)
	unit.getMovementPointer().movePointer(collision_pos)
	unit.forceSetCurrentTarget(null)
	unit.setState(1)

func commandMoveToUnit(unit: Controllable, collider: Controllable, collision_pos: Vector3) -> void:
	unit.setTargetPosition(collider.global_position)
	unit.setSavedTargetPosition(collision_pos)
	unit.getMovementPointer().movePointer(collision_pos)
	unit.setState(1)

func getTeam() -> int: return team
