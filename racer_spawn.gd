class_name RacerSpawn
extends Node

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################
# Adjust number of racers based on slider on HUD main menu


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################
@export_group("Racers")
@export var racer_scene: PackedScene
@export_range(0, 12) var number_of_racers: int = 12

var list_path: String = "user://choices.list"
var y_offset: float = 0.0
var choices_array: Array
var racing: bool = false


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################
func setup_race(mode: int) -> void:
	# Initialize spawner
	# TODO Change number_of_racers to number of lines in choices.list
	#        if number_of_choices < number_of_racers
	#      Display error and don't continue if choices.list is blank
	remove_racers()
	y_offset = 0
	# Get choices array, shuffle the array, and spawn racers
	choices_array = get_choices_array(list_path)
	choices_array.shuffle()
	choices_array.resize(number_of_racers)
	spawn_racers(mode)
	racing = true

func remove_racers() -> void:
	for r in get_children():
		remove_child(r)
		r.queue_free()

func get_choices_array(path: String) -> Array:
	var file: = FileAccess.open(path,FileAccess.READ)
	var choices: String = file.get_var()
	var array: Array = choices.split("\n")
	return array

# TODO Add function to check for number of lines in choices array

func set_medal_colors(top_three_racers: Array) -> void:
	var first_place_choice: String = top_three_racers[0][1]
	var second_place_choice: String = top_three_racers[1][1]
	var third_place_choice: String = top_three_racers[2][1]
	for r in get_children():
		if r.choice == first_place_choice:
			r.medal_color = Color.GOLD
		elif r.choice == second_place_choice:
			r.medal_color = Color.SILVER
		elif r.choice == third_place_choice:
			r.medal_color = Color.PERU
		else:
			r.medal_color = Color.WHITE

func spawn_racers(mode: int = 1) -> void:
	for n in number_of_racers:
		var racer: Racer = racer_scene.instantiate()
		var padding: float = racer.outside_padding
		# Set roll_min based on mode
		if mode == 1: #NORMAL
			racer.roll_min = 1
		elif mode == 2: #STALLING
			racer.roll_min = 0
		else: #PULLBACK
			racer.roll_min = -1
		# Halve time_scale for mode 1
		if mode == 1:
			racer.time_scale = racer.time_scale * 0.5
		#print("mode: " + str(mode))
		racer.position = Vector2(0,y_offset + padding)
		racer.choice = choices_array[n]
		racer.race_end.connect(on_race_end)
		add_child(racer)
		y_offset += racer.rect_size.y + padding

func get_top_three_racers() -> Array:
	var racers: Array = []
	for racer in get_children():
		racers.append([racer.current_progress, racer.choice])
	racers.sort()
	racers.reverse()
	racers.resize(3)
	return racers


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#setup_race()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if racing:
		var top_three_racers: Array = get_top_three_racers()
		emit_signal("top_three", top_three_racers)
		set_medal_colors(top_three_racers)


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_over
signal top_three

func on_race_end(choice: String) -> void:
	racing = false
	emit_signal("race_over", choice)

func _on_hud_race_start(mode: int) -> void:
	setup_race(mode)
	
func _on_hud_clear_racers() -> void:
	racing = false
	remove_racers()
