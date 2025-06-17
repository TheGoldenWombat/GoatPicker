class_name MenuController
extends Control


################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export var main_menu: MainMenu
@export var list_editor: ListEditor
@export var race_setup_menu: RaceSetupMenu
@export var race_scene: RaceScene
@export var post_race_menu: PostRaceMenu
@export var options_menu: OptionsMenu
@export var credits_menu: CreditsMenu

var edit_return_menu: String = "main_menu"

################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func switch_to_main_menu() -> void: 
	for x: Node in get_children():
		if x is MainMenu: x.show()
		else: x.hide()


func switch_to_list_editor() -> void: 
	for x: Node in get_children():
		if x is ListEditor: x.show()
		else: x.hide()


func switch_to_options_menu() -> void: 
	for x: Node in get_children():
		if x is OptionsMenu: x.show()
		else: x.hide()


func switch_to_credits_menu() -> void: 
	for x: Node in get_children():
		if x is CreditsMenu: x.show()
		else: x.hide()


func switch_to_setup_race_menu() -> void: 
	race_setup_menu.number_of_racers = race_scene.get_number_of_racers()
	race_setup_menu.init_race_setup_menu()
	for x: Node in get_children():
		if x is RaceSetupMenu: x.show()
		else: x.hide()


func setup_race_scene() -> void:
	race_scene.number_of_racers = race_setup_menu.number_of_racers
	race_scene.combos_enabled = race_setup_menu.combos_checkbox.button_pressed
	race_scene.attacks_enabled = race_setup_menu.attacks_checkbox.button_pressed

func switch_to_race_scene() -> void:
	for x: Node in get_children():
		if x is RaceScene: x.show()
		else: x.hide()

func start_race_scene() -> void:
	var race_type: int = int(race_setup_menu.race_type_slider.value)
	race_scene.setup_race(race_type)


func show_post_race_menu() -> void:
	post_race_menu.show()


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

# MAIN MENU
func _on_main_menu_setup_race_button_pressed() -> void:
	switch_to_setup_race_menu()

func _on_main_menu_edit_list_button_pressed() -> void:
	switch_to_list_editor()
	edit_return_menu = "main_menu"

func _on_main_menu_options_button_pressed() -> void:
	switch_to_options_menu()


# LIST EDITOR
func _on_list_editor_done_button_pressed() -> void:
	if edit_return_menu == "race_setup":
		switch_to_setup_race_menu()
	else:
		switch_to_main_menu()


# RACE SETUP MENU
func _on_race_setup_menu_edit_list_button_pressed() -> void:
	switch_to_list_editor()
	edit_return_menu = "race_setup"	

func _on_race_setup_menu_menu_button_pressed() -> void:
	switch_to_main_menu()

func _on_race_setup_menu_start_race_button_pressed() -> void:
	setup_race_scene()
	switch_to_race_scene()
	start_race_scene()


# RACE SCENE
func _on_race_scene_race_end(_choice: String) -> void:
	print("race_end signal recived by menu_controller")
	show_post_race_menu()


# POST RACE MENU
func _on_post_race_menu_restart_race_button_pressed() -> void:
	race_scene.stop_all_audio()
	setup_race_scene()
	switch_to_race_scene()
	start_race_scene()

func _on_post_race_menu_setup_new_race_button_pressed() -> void:
	race_scene.stop_all_audio()
	switch_to_setup_race_menu()

func _on_post_race_menu_main_menu_button_pressed() -> void:
	race_scene.stop_all_audio()
	switch_to_main_menu()
