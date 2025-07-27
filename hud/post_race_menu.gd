class_name PostRaceMenu
extends Control

@export var top_label: Label
@export var bottom_label: Label
@export var resume_race_button: Button


func set_pause_label() -> void:
	top_label.show()
	bottom_label.hide()
	top_label.text = "Race paused!"


func set_winner_label(choice: String) -> void:
	top_label.show()
	bottom_label.show()
	top_label.text = "The winner is:"
	bottom_label.text = choice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


signal restart_race_button_pressed
func _on_restart_race_button_pressed() -> void:
	emit_signal("restart_race_button_pressed")
	resume_race_button.hide()
	hide()

signal setup_new_race_button_pressed
func _on_setup_new_race_button_pressed() -> void:
	emit_signal("setup_new_race_button_pressed")
	resume_race_button.hide()
	hide()

signal main_menu_button_pressed
func _on_main_menu_button_pressed() -> void:
	emit_signal("main_menu_button_pressed")
	resume_race_button.hide()
	hide()


func _on_race_scene_race_end(choice: String) -> void:
	set_winner_label(choice)


func _on_race_scene_race_pause() -> void:
	resume_race_button.show()

signal resume_race
func _on_resume_race_button_pressed() -> void:
	emit_signal("resume_race")
	resume_race_button.hide()
	
