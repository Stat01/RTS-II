extends Control

@onready var button_start: Button = $HBoxContainer/VBoxContainer/Button_start
@onready var button_options: Button = $HBoxContainer/VBoxContainer/Button_options
@onready var button_credits: Button = $HBoxContainer/VBoxContainer/Button_credits
@onready var button_exit: Button = $HBoxContainer/VBoxContainer/Button_exit

const MAIN: NodePath = "res://Main.tscn"

#temp
func startDevZero() -> void:
	var ins = load(MAIN).instantiate()
	get_tree().root.add_child(ins)
	#delete self
	$"../..".queue_free()

func _on_button_start_pressed() -> void:
	startDevZero()


func _on_button_options_pressed() -> void:
	pass # Replace with function body.


func _on_button_credits_pressed() -> void:
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	get_tree().quit()
