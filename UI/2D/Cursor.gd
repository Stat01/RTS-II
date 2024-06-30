extends Control

@onready var texture_rect: TextureRect = $TextureRect

const DEFAULT_CURSOR = preload("res://UI/2D/Cursors/Default.png")

const SELECT_ARR: Array = [
	preload("res://UI/2D/Cursors/Select0.png"),
	preload("res://UI/2D/Cursors/Select1.png"),
	preload("res://UI/2D/Cursors/Select2.png"),
	preload("res://UI/2D/Cursors/Select3.png"),
	preload("res://UI/2D/Cursors/Select4.png"),
	preload("res://UI/2D/Cursors/Select5.png"),
	preload("res://UI/2D/Cursors/Select6.png"),
	preload("res://UI/2D/Cursors/Select7.png")
]

const TARGET_CURSOR = preload("res://UI/2D/Cursors/Target.png")

enum {DEFAULT, SELECT, TARGET}

var current_type: int

var rotation_index: int
var rotation_timer: int

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	#set cursor pos
	global_position.x = get_viewport().get_mouse_position().x - (texture_rect.texture.get_width() / 2)
	global_position.y = get_viewport().get_mouse_position().y - (texture_rect.texture.get_height() / 2)
	
	#set cursor type
	match GeneralVars.current_cursor_type:
		DEFAULT:
			if current_type != DEFAULT:
				current_type = DEFAULT
				texture_rect.texture = DEFAULT_CURSOR
		SELECT:
			if current_type != SELECT:
				current_type = SELECT
		TARGET:
			if current_type != TARGET:
				current_type = TARGET
				texture_rect.texture = TARGET_CURSOR

func _physics_process(_delta: float) -> void:
	#rotate if select type
	rotation_timer += 1
	if rotation_timer >= 7:
		rotation_timer = 0
		if current_type == SELECT:
			rotation_index += 1
			texture_rect.texture = SELECT_ARR[rotation_index]
			if rotation_index >= SELECT_ARR.size() - 1:
				rotation_index = 0
	
	#texture rect scale
	if current_type == SELECT:
		texture_rect.scale.y = 0.8
	else:
		texture_rect.scale.y = 1.0
