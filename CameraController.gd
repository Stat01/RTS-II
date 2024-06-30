extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var glitch_effect: ColorRect = $CanvasLayer/Glitch
@onready var nav_mesh: NavigationRegion3D = $"../NavigationRegion3D"

var mouse_pos: Vector2
var mouse_middle_pan_pos: Vector2
var mouse_middle_down: bool = false

var mouse_dragging: bool = false
var pos_1: Vector2 = Vector2.ZERO
var pos_2: Vector2 = Vector2.ZERO
var line: Line2D = Line2D.new()
var box_pos_1: Vector2
var box_pos_2: Vector2
var dragging_box: bool

var target_zoom: float
var pan_direction: Vector2
var panning: bool

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
	line.width = 5
	line.default_color = Color(1,0,0)
	
	#AI debug
	ai_master = AI_MASTER.instantiate()

func _physics_process(delta: float) -> void:
	
#region Camera panning
	pan_direction = mouse_pos - mouse_middle_pan_pos
	pan_direction = pan_direction / 64
	pan_direction = pan_direction * Settings.camera_pan_speed
	##left
	if mouse_pos.x < get_viewport().get_visible_rect().size.x - (get_viewport().get_visible_rect().size.x - 30) or Input.is_action_pressed("camera_left"):
		pan_direction.x -= 1
	##right
	if mouse_pos.x > get_viewport().get_visible_rect().size.x - 30 or Input.is_action_pressed("camera_right"):
		pan_direction.x += 1
	##forward
	if mouse_pos.y < get_viewport().get_visible_rect().size.y - (get_viewport().get_visible_rect().size.y - 30) or Input.is_action_pressed("camera_forward"):
		pan_direction.y -= 1
	##backward
	if mouse_pos.y > get_viewport().get_visible_rect().size.y - 30 or Input.is_action_pressed("camera_backward"):
		pan_direction.y += 1
	if panning:
		global_position += Vector3(pan_direction.x, 0, pan_direction.y)
#endregion
	
#region Update zoom level
	global_position.y = lerp(global_position.y, target_zoom, 0.5)
#endregion
	
#region Cursors
	var info: Dictionary = getWorldClickPosition()
	if "position" in info:
		var collider = info["collider"]
		if collider is CharacterBody3D and collider.has_method("getTeam"):
			match collider.getTeam():
				0:	#Neutral
					GeneralVars.current_cursor_type = 0
				1:	#Friendly
					GeneralVars.current_cursor_type = 1
				2:	#Enemy
					if collider.visible:
						if !PlayerVars.getSelectedUnits().is_empty():
							GeneralVars.current_cursor_type = 2
						else:
							GeneralVars.current_cursor_type = 1
		else:
			#Not hovering over controllable
			GeneralVars.current_cursor_type = 0
	else:
		#Mouse out of bounds idk safety or something
		GeneralVars.current_cursor_type = 0
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
	
	
	
	
	#AI debug
	if Input.is_action_just_pressed("debugbutton"):
		get_tree().root.get_node("Main").get_node("AI Slave").queue_free()
		#var ins = AI_SLAVE.instantiate()
		#var units: Array[CharacterBody3D]
		#for unit: Controllable in GeneralVars.getUnitsList().get_children():
		#	if unit.getName() == "Rasmus":
		#		units.append(unit)
		#ins.initialize(0, units, false, ai_master, GeneralVars.getStructureList().get_children()[0], )
		#get_tree().root.add_child(ins)

func minimapMoveCamera(pos: Vector2) -> void:
	var real_mouse_pos := pos * GeneralVars.getMapSize() * 2
	global_position = Vector3(real_mouse_pos.x - GeneralVars.getMapSize() * 2, global_position.y, real_mouse_pos.y)

func _unhandled_input(event: InputEvent) -> void:
	#update mouse pos
	if event is InputEventMouseMotion:
		mouse_pos = event.position
	
#region Camera zoom and panning
	elif event is InputEventMouseButton:
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
	target_zoom = clamp(target_zoom, max_zoom, min_zoom)
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
#endregion
	
#region Draw box
	if event.is_action_pressed("left_click") and !dragging_box:
		dragging_box = true
		box_pos_1 = get_viewport().get_mouse_position() 
	
	if dragging_box:
		box_pos_2 = get_viewport().get_mouse_position()
		line.clear_points()
		if line.get_parent() == null:
			get_tree().root.add_child(line)
		var points: Array[Vector2] = [box_pos_1, Vector2(box_pos_1.x, box_pos_2.y), box_pos_2, Vector2(box_pos_2.x, box_pos_1.y), box_pos_1]
		for point in points:
			line.add_point(point)
		
	if event.is_action_released("left_click") and dragging_box:
		dragging_box = false
		line.clear_points()
#endregion
	
	#Delete Controllable, maybe debug?
	if event.is_action_pressed("delete"):
		for unit in PlayerVars.getSelectedUnits():
			unit.die()

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
			for unit in PlayerVars.getSelectedUnits():
				unit.setIsSelected(false)
			PlayerVars.clearSelectedUnits()
		
		if collider != null and collider is CharacterBody3D and collider.visible:
			var unit: CharacterBody3D = collider
			if shift_pressed and unit.getIsSelected() == true:
				PlayerVars.removeFromSelectedUnits(unit)
				unit.setIsSelected(false)
			else:
				PlayerVars.addToSelectedUnits(unit)
				unit.setIsSelected(true)
				# and (collider.is_in_group("Team1") or collider.is_in_group("Team0"))

func startSelectionBox() -> void:
	var result = getWorldClickPosition()
	if "position" in result:
		pos_1 = Vector2(result["position"].x, result["position"].z)

func endSelectionBox() -> void:
	var result = getWorldClickPosition()
	if "position" in result:
		pos_2 = Vector2(result["position"].x, result["position"].z)
		
		for unit in PlayerVars.getAllUnits():
			if !unit.is_building:
				#start top left
				if pos_1.x < pos_2.x and pos_1.y < pos_2.y:
					if unit.global_position.x > pos_1.x and unit.global_position.x < pos_2.x:
						if unit.global_position.z > pos_1.y and unit.global_position.z < pos_2.y:
							PlayerVars.addToSelectedUnits(unit)
							unit.setIsSelected(true)
				
				#start bottom left
				if pos_1.x < pos_2.x and pos_1.y > pos_2.y:
					if unit.global_position.x > pos_1.x and unit.global_position.x < pos_2.x:
						if unit.global_position.z < pos_1.y and unit.global_position.z > pos_2.y:
							PlayerVars.addToSelectedUnits(unit)
							unit.setIsSelected(true)
				
				#start bottom right
				if pos_1.x > pos_2.x and pos_1.y > pos_2.y:
					if unit.global_position.x < pos_1.x and unit.global_position.x > pos_2.x:
						if unit.global_position.z < pos_1.y and unit.global_position.z > pos_2.y:
							PlayerVars.addToSelectedUnits(unit)
							unit.setIsSelected(true)
				
				#start top right
				if pos_1.x > pos_2.x and pos_1.y < pos_2.y:
					if unit.global_position.x < pos_1.x and unit.global_position.x > pos_2.x:
						if unit.global_position.z > pos_1.y and unit.global_position.z < pos_2.y:
							PlayerVars.addToSelectedUnits(unit)
							unit.setIsSelected(true)

func issueCommand() -> void:
	var result = getWorldClickPosition()
	if "collider" in result:
		var collider = result["collider"]
		var collision_pos = result["position"]
		
		for unit in PlayerVars.getSelectedUnits():
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
