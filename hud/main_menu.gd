class_name MainMenu
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal setup_race_button_pressed
func _on_setup_race_button_pressed() -> void:
	emit_signal("setup_race_button_pressed")


signal edit_list_button_pressed
func _on_edit_list_button_pressed() -> void:
	emit_signal("edit_list_button_pressed")


signal options_button_pressed
func _on_options_button_pressed() -> void:
	emit_signal("options_button_pressed")


func _on_fullscreen_button_pressed() -> void:
	if get_window().mode == Window.MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
