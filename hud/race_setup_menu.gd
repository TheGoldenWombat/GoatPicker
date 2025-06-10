class_name RaceSetupMenu
extends Control

@export var race_type_slider: Slider
@export var race_mode_label: Label
@export var num_racers_slider: Slider
@export var num_racers_label: Label
@export var combos_checkbox: CheckBox
@export var attacks_checkbox: CheckBox

var number_of_racers: int = 0


func init_race_setup_menu() -> void:
	num_racers_slider.max_value = number_of_racers
	num_racers_slider.value = num_racers_slider.max_value


func update_race_mode_label() -> void:
	race_mode_label.text = str(int(race_type_slider.value))


func update_num_racers_label() -> void:
	num_racers_label.text = str(int(num_racers_slider.value))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_race_mode_label()


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


func _on_race_type_slider_value_changed(_value: float) -> void:
	update_race_mode_label()


func _on_num_racers_slider_value_changed(_value: float) -> void:
	update_num_racers_label()
	number_of_racers = int(num_racers_slider.value)
