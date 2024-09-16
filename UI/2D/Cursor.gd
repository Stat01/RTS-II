extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	#set cursor pos
	global_position.x = get_viewport().get_mouse_position().x
	global_position.y = get_viewport().get_mouse_position().y
	
	#set cursor type
	match GeneralVars.current_cursor_type:
		0:
			visible = true
		1:
			visible = false
		2:
			visible = false

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
