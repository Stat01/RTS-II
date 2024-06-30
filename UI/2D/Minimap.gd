extends SubViewportContainer

@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var refresh_timer: Timer = $"Refresh timer"
@onready var minimap_noise: Sprite3D = $"SubViewport/Camera3D/minimap noise"
@onready var minimap_picture: Sprite3D = $"SubViewport/Camera3D/minimap picture"

var dragging: bool

##In seconds per frame
@export var refresh_rate: float
func _ready() -> void:
	var map_size := GeneralVars.getMapSize()
	camera.size = map_size * 2
	minimap_noise.scale = Vector3(map_size * 1,map_size * 1,map_size * 1)
	minimap_picture.scale = Vector3(map_size * 0.4,map_size * 0.4,map_size * 0.4)
	camera.global_position = Vector3(-map_size, 512, map_size)
	refresh_timer.start(refresh_rate)
	refreshMinimap()

func refreshMinimap() -> void:
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	if PlayerVars.hasRadar():
		#Minimap need 100 Energy to function
		if PlayerVars.getEnergyRemaining() <= 100:
			minimap_noise.visible = true
			minimap_noise.get("texture").get("noise").set("seed", randi_range(0,1024))
			camera.environment.adjustment_enabled = false
		else:
			minimap_noise.visible = false
			minimap_picture.visible = false
			camera.environment.adjustment_enabled = true
	else:
		minimap_picture.visible = true
		minimap_noise.visible = false
		camera.environment.adjustment_enabled = false

func _gui_input(event: InputEvent) -> void:
	if PlayerVars.hasRadar() and PlayerVars.getEnergyRemaining() > 100 and event is InputEventMouseButton and event.button_index == 1:
		var mouse_pos := Vector2(event.position.x / size.x, event.position.y / size.y)
		SignalManager.minimap_camera_position_changed.emit(mouse_pos)
