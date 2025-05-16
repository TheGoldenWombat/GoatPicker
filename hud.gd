extends CanvasLayer

################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################
@export var center_message: Label
@export var top_three_list: Label
@export var mode_1_button: Button
@export var mode_2_button: Button
@export var mode_3_button: Button
@export var abort_race: Button
@export var edit_list_button: Button
@export var list_editor: ListEditor

const TITLE_MESSAGE: String = "Movie Picker 3000"


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#center_message.hide()
	#abort_race.hide()
	#top_three_list.hide()
	#list_editor.hide()
	initialize_main_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func initialize_main_menu():
	show_main_menu_buttons()
	top_three_list.hide()
	list_editor.hide()
	abort_race.hide()
	center_message.text = TITLE_MESSAGE
	center_message.show()
	emit_signal("clear_racers")

func start_race(mode: int = 1):
	hide_main_menu_buttons()
	abort_race.show()
	center_message.hide()
	top_three_list.show()
	emit_signal("race_start", mode)
	
func hide_main_menu_buttons():
	mode_1_button.hide()
	mode_2_button.hide()
	mode_3_button.hide()
	edit_list_button.hide()
	
func show_main_menu_buttons():
	mode_1_button.show()
	mode_2_button.show()
	mode_3_button.show()
	edit_list_button.show()
	

################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_start
signal clear_racers

func _on_racer_spawn_race_over(movie_title) -> void:
	center_message.text = "The winner is: \n" + movie_title
	center_message.show()
	abort_race.hide()
	show_main_menu_buttons()
	top_three_list.show()

func _on_racer_spawn_top_three(top_three) -> void:
	var first_progress = str(clamp(top_three[0][0],0.00,100.00)).pad_decimals(2) + "%"
	var first_title = top_three[0][1]
	var second_progress = str(clamp(top_three[1][0],0.00,100.00)).pad_decimals(2) + "%"
	var second_title = top_three[1][1]
	var third_progress = str(clamp(top_three[2][0],0.00,100.00)).pad_decimals(2) + "%"
	var third_title = top_three[2][1]
	top_three_list.text = first_progress + " - " + first_title + "\n" + \
					  second_progress + " - " + second_title + "\n" + \
					  third_progress + " - " + third_title


func _on_edit_list_button_pressed() -> void:
	list_editor.show()


func _on_start_mode_1_button_pressed() -> void:
	start_race(1)


func _on_start_mode_2_button_pressed() -> void:
	start_race(2)


func _on_start_mode_3_button_pressed() -> void:
	start_race(3)


func _on_abort_race_button_pressed() -> void:
	get_tree().call_group("racers", "end_race")
	center_message.text = "Race aborted!"
	center_message.show()
	abort_race.hide()
	show_main_menu_buttons()
	top_three_list.show()


func _on_list_editor_close_editor() -> void:
	initialize_main_menu()
