class_name PostRaceMenu
extends Control

@export var top_label: Label
@export var bottom_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


signal restart_race_button_pressed
func _on_restart_race_button_pressed() -> void:
	emit_signal("restart_race_button_pressed")
	hide()

signal setup_new_race_button_pressed
func _on_setup_new_race_button_pressed() -> void:
	emit_signal("setup_new_race_button_pressed")
	hide()

signal main_menu_button_pressed
func _on_main_menu_button_pressed() -> void:
	emit_signal("main_menu_button_pressed")
	hide()


func _on_race_scene_race_end(choice: String) -> void:
	print("race_end signal recived by post_race_menu")
	bottom_label.text = choice
