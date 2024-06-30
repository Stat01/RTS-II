extends Control

@onready var general_ui: VBoxContainer = $"General UI"

@onready var selection_ui: VBoxContainer = $SelectionUI
@onready var unit_name: Label = $"SelectionUI/HBoxContainer2/NinePatchRect/HBoxContainer/VBoxContainer/Unit Name"
@onready var unit_stats: RichTextLabel = $"SelectionUI/HBoxContainer2/NinePatchRect/HBoxContainer/VBoxContainer/Unit Stats"

@onready var building_ui: VBoxContainer = $"Building UI"
@onready var omnite_indicator: TextureRect = $"Building UI/HBoxContainer/VBoxContainer/Omnite indicator"
@onready var omnite_counter: Label = $"Building UI/HBoxContainer/VBoxContainer/Omnite Counter"
@onready var fps_counter: Label = $"Building UI/HBoxContainer/VBoxContainer/Omnite Counter2"
@onready var power_bar: ProgressBar = $"Building UI/HBoxContainer/PowerBar"

var omnite: float

func _process(_delta: float) -> void:
	
	fps_counter.text = str(Engine.get_frames_per_second())
	
	#selection ui
	if !PlayerVars.getSelectedUnits().is_empty():
		var to_show = PlayerVars.getSelectedUnits()[0]
		hideAllUI()
		selection_ui.set_visible(true)
		#general_ui.set_visible(true)
		updateSelectionUI(to_show)
		
	else:
		hideAllUI()
		#general_ui.set_visible(true)
	
	
	#Omnite indicator
	var omnite_scale: float = (PlayerVars.getOmnite() as float / PlayerVars.getMaxOmnite() as float)
	
	omnite = lerp(omnite, omnite_scale, 0.01)
	omnite_indicator.material.set("shader_parameter/fV", omnite)
	omnite_counter.text = str(PlayerVars.getOmnite()) + " / " + str(PlayerVars.getMaxOmnite())
	
	#Power bar
	power_bar.value = PlayerVars.getCurrentEnergyUsage()
	power_bar.max_value = PlayerVars.getMaxEnergyUsage()
	
	if PlayerVars.getEnergyRemaining() < 0:
		power_bar.get("theme_override_styles/background").set("bg_color", Color.DARK_RED)
		power_bar.get("theme_override_styles/fill").set("bg_color", Color.RED)
	elif PlayerVars.getEnergyRemaining() <= 100:
		power_bar.get("theme_override_styles/background").set("bg_color", Color.ORANGE)
		power_bar.get("theme_override_styles/fill").set("bg_color", Color.YELLOW)
	else:
		power_bar.get("theme_override_styles/background").set("bg_color", Color.ROYAL_BLUE)
		power_bar.get("theme_override_styles/fill").set("bg_color", Color.DODGER_BLUE)

func hideAllUI() -> void:
	selection_ui.hide()
	general_ui.hide()
	


func updateSelectionUI(unit: CharacterBody3D) -> void:
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
		
		unit_stats.text += "\nArmour  " + str(unit.getArmour())

		if (unit.getIsBuilding() and unit.getDamage() > 0) or !unit.getIsBuilding():
			unit_stats.text += "			Attack  " + str(unit.getDamage())
		
		unit_stats.text += "\n" + type

		if (unit.getIsBuilding() and unit.getDamage() > 0) or !unit.getIsBuilding():
			unit_stats.text += "			" + damage_type
