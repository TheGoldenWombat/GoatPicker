extends CanvasLayer

################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MovieAnnouncement.hide()
	$AbortRaceButton.hide()
	$TopThree.hide()
	$ListEditor.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func initialize_main_menu():
	show_main_menu_buttons()
	$TopThree.hide()
	$ListEditor.hide()
	$AbortRaceButton.hide()
	$MovieAnnouncement.hide()
	emit_signal("clear_racers")

func start_race(mode: int = 1):
	hide_main_menu_buttons()
	$AbortRaceButton.show()
	$MovieAnnouncement.hide()
	$TopThree.show()
	emit_signal("race_start", mode)
	
func hide_main_menu_buttons():
	$StartMode1Button.hide()
	$StartMode2Button.hide()
	$StartMode3Button.hide()
	$EditListButton.hide()
	
func show_main_menu_buttons():
	$StartMode1Button.show()
	$StartMode2Button.show()
	$StartMode3Button.show()
	$EditListButton.show()
	

################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_start
signal clear_racers

func _on_racer_spawn_race_over(movie_title) -> void:
	$MovieAnnouncement.text = "The winner is: \n" + movie_title
	$MovieAnnouncement.show()
	$AbortRaceButton.hide()
	show_main_menu_buttons()
	$TopThree.show()

func _on_racer_spawn_top_three(top_three) -> void:
	var first_progress = str(clamp(top_three[0][0],0.00,100.00)).pad_decimals(2) + "%"
	var first_title = top_three[0][1]
	var second_progress = str(clamp(top_three[1][0],0.00,100.00)).pad_decimals(2) + "%"
	var second_title = top_three[1][1]
	var third_progress = str(clamp(top_three[2][0],0.00,100.00)).pad_decimals(2) + "%"
	var third_title = top_three[2][1]
	$TopThree.text = first_progress + " - " + first_title + "\n" + \
					  second_progress + " - " + second_title + "\n" + \
					  third_progress + " - " + third_title


func _on_edit_list_button_pressed() -> void:
	$ListEditor.show()


func _on_start_mode_1_button_pressed() -> void:
	start_race(1)


func _on_start_mode_2_button_pressed() -> void:
	start_race(2)


func _on_start_mode_3_button_pressed() -> void:
	start_race(3)


func _on_abort_race_button_pressed() -> void:
	get_tree().call_group("racers", "end_race")
	$MovieAnnouncement.text = "Race aborted!"
	$MovieAnnouncement.show()
	$AbortRaceButton.hide()
	show_main_menu_buttons()
	$TopThree.show()


func _on_list_editor_close_editor() -> void:
	initialize_main_menu()
