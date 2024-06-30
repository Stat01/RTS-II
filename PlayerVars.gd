extends Node

func _process(_delta: float) -> void:
	minerals = clamp(minerals, 0, max_minerals)

#Selected units array
var selected_units: Array[CharacterBody3D] = []
func getSelectedUnits() -> Array[CharacterBody3D]:	return selected_units
func setSelectedUnits(arr: Array[CharacterBody3D]) -> void:
	selected_units.clear()
	selected_units.append_array(arr)
func addToSelectedUnits(unit: CharacterBody3D) -> void:	selected_units.append(unit)
func clearSelectedUnits() -> void:	selected_units.clear()
func removeFromSelectedUnits(unit: CharacterBody3D) -> void:
	if unit in selected_units:
		selected_units.erase(unit)
#-------------------------------#

#All units array
var all_units: Array[CharacterBody3D] = []
func getAllUnits() -> Array[CharacterBody3D]:	return all_units
func setAllUnits(arr: Array[CharacterBody3D]) -> void:
	selected_units.clear()
	selected_units.append_array(arr)
func addToAllUnits(unit: CharacterBody3D) -> void:	all_units.append(unit)
func clearAllUnits() -> void:	all_units.clear()
func removeFromAllUnits(unit: CharacterBody3D) -> void:
	if unit in all_units:
		all_units.erase(unit)
#-------------------------------#

#Omnite
var minerals: int = 500
var max_minerals: int = 500
func getOmnite() -> int:	return minerals
func setOmnite(i: int) -> void: minerals = i
func changeOmnite(i: int) -> void: minerals += i
func getMaxOmnite() -> int: return max_minerals
func setMaxOmnite(i: int) -> void: max_minerals = i
func changeMaxOmnite(i: int) -> void: max_minerals += i
#-------------------------------#

#Energy
var current_energy_usage: int
var max_energy_usage: int
func getCurrentEnergyUsage() -> int: return current_energy_usage
func setCurrentEnergyUsage(i: int) -> void: current_energy_usage = i
func getMaxEnergyUsage() -> int: return max_energy_usage
func setMaxEnergyUsage(i: int) -> void: max_energy_usage = i
func changeCurrentEnergyUsage(i: int) -> void: current_energy_usage += i
func changeMaxEnergyUsage(i: int) -> void: max_energy_usage += i
func getEnergyRemaining() -> int: return max_energy_usage - current_energy_usage
#-------------------------------#

#Building mode
var building_mode: bool
var active_building: PackedScene
var building_blocked: bool
func getBuildingMode() -> bool: return building_mode
func setBuildingMode(i: bool) -> void: building_mode = i
func getActiveBuilding() -> PackedScene: return active_building
func setActiveBuilding(i: PackedScene) -> void: active_building = i
func getBuildingBlocked() -> bool: return building_blocked
func setBuildingBlocked(i: bool) -> void: building_blocked = i
#-------------------------------#

#Unit production
var vehicledepot_building: CharacterBody3D
var factory_building: CharacterBody3D
func getVehicleDepotBuilding() -> CharacterBody3D: return vehicledepot_building
func setVehicleDepotBuilding(i: CharacterBody3D) -> void: vehicledepot_building = i
func hasVehicleDepotBuilding() -> bool: return false if vehicledepot_building == null else true
func getFactoryBuilding() -> CharacterBody3D: return factory_building
func setFactoryBuilding(i: CharacterBody3D) -> void: factory_building = i
func hasFactoryBuilding() -> bool: return false if factory_building == null else true
#-------------------------------#

#Building unlocks
var buildings: Array[String]
func getBuildings() -> Array[String]: return buildings
#-------------------------------#

#Radar
var has_radar: bool
func setHasRadar(i: bool) -> void: has_radar = i
func hasRadar() -> bool: return has_radar
#-------------------------------#
