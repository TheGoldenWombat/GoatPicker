class_name HUD
extends CanvasLayer

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################

# Add slider to choose number of racers
# 	Maximum racers should be based on the number of lines in choices.list
# 	If lines < maximum then maximum = lines


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export var center_message: Label
@export var error_message: Label
@export var top_three_list: Label
@export var mode_1_button: Button
@export var mode_2_button: Button
@export var mode_3_button: Button
@export var abort_race: Button
@export var edit_list_button: Button
@export var list_editor: ListEditor
@export var racer_spawn: RacerSpawn

var racer_spawn_scene: PackedScene = preload("res://racer_spawn.tscn")
const TITLE_MESSAGE: String = "Goat's Choice Picker 3000"
var choices_path: String = "user://choices.list"


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_main_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func initialize_main_menu() -> void:
	show_main_menu_buttons()
	top_three_list.hide()
	list_editor.hide()
	abort_race.hide()
	center_message.text = TITLE_MESSAGE
	center_message.show()
	error_message.hide()
	emit_signal("clear_racers")


## Get list of choices from choices.list and read them into an array
func get_choices_array(path: String) -> Array:
	var file: = FileAccess.open(path,FileAccess.READ)
	var choices: String = file.get_var()
	var array: Array = choices.split("\n")
	#Filter null and blanks
	array = array.filter(func(element: Variant) -> bool: return element!=null)
	array = array.filter(func(element: Variant) -> bool: return element!="")
	return array


func choices_available() -> bool:
	return get_choices_array(choices_path).size() > 0


func error_choices_unavailable() -> void:
	if !error_message.visible:
		error_message.text = "No valid choices available! \n" + \
							  "Add choices using the 'Edit List' button"
		error_message.show()
		await get_tree().create_timer(3).timeout
		error_message.hide()


func start_race(mode: int = 1) -> void:
	if choices_available():
		hide_main_menu_buttons()
		abort_race.show()
		center_message.hide()
		#top_three_list.show()
		emit_signal("race_start", mode)
	else:
		error_choices_unavailable()


func hide_main_menu_buttons() -> void:
	mode_1_button.hide()
	mode_2_button.hide()
	mode_3_button.hide()
	edit_list_button.hide()


func show_main_menu_buttons() -> void:
	mode_1_button.show()
	mode_2_button.show()
	mode_3_button.show()
	edit_list_button.show()

func refresh_RacerSpawn():
	racer_spawn.queue_free()
	racer_spawn = racer_spawn_scene.instantiate()
	add_sibling(racer_spawn)
	race_start.connect(racer_spawn._on_hud_race_start)
	clear_racers.connect(racer_spawn._on_hud_clear_racers)
	racer_spawn.race_over.connect(_on_racer_spawn_race_over)
	racer_spawn.show_top_three.connect(_on_racer_spawn_show_top_three)
	racer_spawn.top_three.connect(_on_racer_spawn_top_three)
	mode_1_button.pressed.connect(_on_start_mode_1_button_pressed)
	mode_2_button.pressed.connect(_on_start_mode_2_button_pressed)
	mode_3_button.pressed.connect(_on_start_mode_3_button_pressed)
	#racer_spawn.racer_scene = Racer.new()

################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_start
signal clear_racers


func _on_racer_spawn_race_over(choice: String) -> void:
	center_message.text = "The winner is: \n" + choice
	center_message.show()
	abort_race.hide()
	show_main_menu_buttons()
	top_three_list.show()


func _on_racer_spawn_top_three(top_three_text: String) -> void:
	top_three_list.text = top_three_text


func _on_edit_list_button_pressed() -> void:
	list_editor.load_list()
	list_editor.show()


func _on_start_mode_1_button_pressed() -> void:
	start_race(1)


func _on_start_mode_2_button_pressed() -> void:
	start_race(2)


func _on_start_mode_3_button_pressed() -> void:
	start_race(3)


func _on_abort_race_button_pressed() -> void:
	get_tree().call_group("racers", "end_race")
	refresh_RacerSpawn()
	center_message.text = "Race aborted!"
	center_message.show()
	abort_race.hide()
	show_main_menu_buttons()
	top_three_list.hide()


func _on_list_editor_close_editor() -> void:
	initialize_main_menu()


func _on_racer_spawn_show_top_three() -> void:
	top_three_list.show()
