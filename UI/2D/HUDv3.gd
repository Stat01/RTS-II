extends Control

@onready var unit_name: Label = $"VBoxContainer/HBoxContainer/VBoxContainer3/AspectRatioContainer/TextureRect/VBoxContainer/Unit Name"
@onready var unit_stats: RichTextLabel = $"VBoxContainer/HBoxContainer/VBoxContainer3/AspectRatioContainer/TextureRect/VBoxContainer/Unit Stats"

@onready var selection_ui: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer3/AspectRatioContainer/TextureRect/VBoxContainer

@onready var pause_menu: HBoxContainer = $PauseMenu

@onready var omnite_indicator: TextureRect = $"VBoxContainer/HBoxContainer/VBoxContainer3/HBoxContainer/AspectRatioContainer2/Omnite indicator"
@onready var omnite_counter: Label = $"VBoxContainer/HBoxContainer/VBoxContainer3/HBoxContainer/AspectRatioContainer2/Omnite indicator/Omnite Counter"
@onready var fps_counter: Label = $"VBoxContainer/FPS Counter"
@onready var power_bar: ProgressBar = $VBoxContainer/HBoxContainer/VBoxContainer2/AspectRatioContainer2/HBoxContainer/VBoxContainer/TextureRect/PowerBar

@onready var cursor: Control = $Cursor

##options menu stuff
@onready var options_menu: HBoxContainer = $OptionsMenu
@onready var check_button_edge_pan: CheckButton = $OptionsMenu/VBoxContainer/NinePatchRect/HBoxContainer/VBoxContainer/CheckButtonEdgePan
@onready var slider_edge_pan_speed: HSlider = $OptionsMenu/VBoxContainer/NinePatchRect/HBoxContainer/VBoxContainer/SliderEdgePanSpeed
@onready var slider_pan_speed: HSlider = $OptionsMenu/VBoxContainer/NinePatchRect/HBoxContainer/VBoxContainer/SliderPanSpeed
@onready var option_button_shadows: OptionButton = $OptionsMenu/VBoxContainer/NinePatchRect/HBoxContainer/VBoxContainer2/OptionButtonShadows
@onready var slider_shadow_distance: HSlider = $OptionsMenu/VBoxContainer/NinePatchRect/HBoxContainer/VBoxContainer2/SliderShadowDistance
@onready var check_button_low_end_cpu: CheckButton = $OptionsMenu/VBoxContainer/NinePatchRect/HBoxContainer/VBoxContainer/CheckButtonLowEndCPU


const MAIN_MENU: NodePath = "res://MainMenu.tscn"

var omnite: float

@export var team: int

func _ready() -> void:
	initializeOptions()

func _process(_delta: float) -> void:
	
	fps_counter.text = str(Engine.get_frames_per_second()) + "fps"
	
	#selection ui
	if !GeneralVars.getTeamVarList(getTeam()).getSelectedUnits().is_empty():
		var to_show = GeneralVars.getTeamVarList(getTeam()).getSelectedUnits()[0]
		if is_instance_valid(to_show):
			selection_ui.show()
			updateSelectionUI(to_show)
		
	else:
		selection_ui.hide()
	
	#Omnite indicator
	var omnite_scale: float = (GeneralVars.getTeamVarList(getTeam()).getOmnite() as float / GeneralVars.getTeamVarList(getTeam()).getMaxOmnite() as float)
	
	omnite = lerp(omnite, omnite_scale, 0.01)
	omnite_indicator.material.set("shader_parameter/fV", omnite)
	omnite_counter.text = str(GeneralVars.getTeamVarList(getTeam()).getOmnite()) + " / " + str(GeneralVars.getTeamVarList(getTeam()).getMaxOmnite())
	
	#Power bar
	power_bar.value = GeneralVars.getTeamVarList(getTeam()).getCurrentEnergyUsage()
	power_bar.max_value = GeneralVars.getTeamVarList(getTeam()).getMaxEnergyUsage()
	
	if GeneralVars.getTeamVarList(getTeam()).getEnergyRemaining() < 0:
		power_bar.get("theme_override_styles/background").set("bg_color", Color.DARK_RED)
		power_bar.get("theme_override_styles/fill").set("bg_color", Color.RED)
	elif GeneralVars.getTeamVarList(getTeam()).getEnergyRemaining() <= 100:
		power_bar.get("theme_override_styles/background").set("bg_color", Color.ORANGE)
		power_bar.get("theme_override_styles/fill").set("bg_color", Color.YELLOW)
	else:
		power_bar.get("theme_override_styles/background").set("bg_color", Color.ROYAL_BLUE)
		power_bar.get("theme_override_styles/fill").set("bg_color", Color.DODGER_BLUE)

func updateSelectionUI(unit: Controllable) -> void:
	unit_name.text = unit.getName()
	
	unit_stats.text = ""
	if !unit.getIsInvincible():
		unit_stats.text = str(unit.getHealth()) + " / " + str(unit.getMaxHealth())
		
		var type: String
		match unit.getType():
			0:	type = "Light"
			1:	type = "Heavy"
			2:	type = "Structure"
		var damage_type: String
		match unit.getDamageType():
			0:	damage_type = "Light"
			1:	damage_type = "Heavy"
			2:	damage_type = "Structure"
		
		if (unit.getIsBuilding() and unit.getDamage() > 0) or !unit.getIsBuilding():
			unit_stats.text += "			Kills  " + str(unit.getKills())
		elif unit.getName() == "Mining Rig":
			unit_stats.text += "			Yield " + str(unit.omnite_yield)
		
		unit_stats.text += "\nArmour  " + str(unit.getArmour())

		if (unit.getIsBuilding() and unit.getDamage() > 0) or !unit.getIsBuilding():
			unit_stats.text += "			Attack  " + str(unit.getDamage())
		
		unit_stats.text += "\n" + type

		if (unit.getIsBuilding() and unit.getDamage() > 0) or !unit.getIsBuilding():
			unit_stats.text += "			" + damage_type
	
	elif unit.getName() == "Omnite Cluster":
		unit_stats.text = str(unit.amount)

func togglePauseMenu() -> void:
	if pause_menu.visible == false:
		pause_menu.visible = true
		GeneralVars.setPaused(true)
		return
	pause_menu.visible = false
	GeneralVars.setPaused(false)

func exitToMainMenu() -> void:
	var ins = load(MAIN_MENU).instantiate()
	get_tree().root.add_child(ins)
	#delete self
	$"../..".queue_free()

func enterOptionsMenu() -> void:
	toggleOptionsMenu()

func toggleOptionsMenu() -> void:
	if options_menu.visible == false:
		options_menu.visible = true
		return
	options_menu.visible = false

func resume() -> void:
	togglePauseMenu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		togglePauseMenu()
		options_menu.visible = false

##Options buttons n' shit
func initializeOptions() -> void:
	check_button_edge_pan.button_pressed = Settings.edge_pan
	slider_edge_pan_speed.value = Settings.camera_edge_pan_speed
	slider_pan_speed.value = Settings.camera_pan_speed
	option_button_shadows.selected = Settings.shadow_quality
	slider_shadow_distance.value = Settings.shadow_distance
	check_button_low_end_cpu.button_pressed = Settings.low_end_cpu
	

func setEdgePan(i: bool) -> void:	Settings.edge_pan = i
func setEdgePanSpeed(i: float) -> void:	Settings.camera_edge_pan_speed = i
func setPanSpeed(i: float) -> void:	Settings.camera_pan_speed = i
func setShadowQuality(i: int) -> void:	
	Settings.shadow_quality = i
	Settings.shadow_quality_changed.emit(i)
func setShadowDistance(i: float) -> void:
	Settings.shadow_distance = i
	Settings.shadow_distance_changed.emit(i)
func setLowEndCPU(i: bool) -> void:
	Settings.low_end_cpu = i

func getTeam() -> int: return team
