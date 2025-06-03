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


func switch_to_setup_race_menu() -> void: 
	for x: Node in get_children():
		if x is RaceSetupMenu: x.show()
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


func switch_to_race_scene() -> void: 
	for x: Node in get_children():
		if x is RaceScene: x.show()
		else: x.hide()


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
	switch_to_race_scene()
