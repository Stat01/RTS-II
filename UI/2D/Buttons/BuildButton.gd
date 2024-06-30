extends Control

@export var unit: PackedScene
@export var is_structure_button: bool

@export var print_locked: bool

@onready var texture_button: TextureButton = $TextureButton

func _ready() -> void:
	texture_button.unit = unit
	texture_button.is_structure_button = is_structure_button
	texture_button.print_locked = print_locked
