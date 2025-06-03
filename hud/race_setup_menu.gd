class_name RaceSetupMenu
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


signal edit_list_button_pressed
func _on_edit_list_button_pressed() -> void:
	emit_signal("edit_list_button_pressed")

signal start_race_button_pressed
func _on_start_race_button_pressed() -> void:
	emit_signal("start_race_button_pressed")

signal menu_button_pressed
func _on_main_menu_button_pressed() -> void:
	emit_signal("menu_button_pressed")
