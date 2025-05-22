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
@export_range(0, 12) var max_racers: int


var number_of_racers: int = max_racers
var list_path: String = "user://choices.list"
var y_offset: float = 0.0
var choices_array: Array
var racing: bool = false


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################
func setup_race(mode: int) -> void:
	# Initialize spawner
	remove_racers()
	y_offset = 0
	number_of_racers = max_racers
	# Get choices array, adjust # of racers, shuffle the array, and spawn racers
	choices_array = get_choices_array(list_path)
	var number_of_choices: int = choices_array.size()
	if number_of_choices < number_of_racers: number_of_racers = number_of_choices
	choices_array.shuffle()
	choices_array.resize(number_of_racers)
	spawn_racers(mode)
	racing = true


## Removes all racers from racer_spawn
func remove_racers() -> void:
	for r in get_children():
		remove_child(r)
		r.queue_free()


## Get list of choices from choices.list and read them into an array
func get_choices_array(path: String) -> Array:
	var file: = FileAccess.open(path,FileAccess.READ)
	var choices: String = file.get_var()
	var array: Array = choices.split("\n")
	#Filter null and blanks
	array = array.filter(func(element: Variant) -> bool: return element!=null)
	array = array.filter(func(element: Variant) -> bool: return element!="")
	return array


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


func get_top_three_array() -> Array:
	var racers: Array = []
	for racer in get_children():
		racers.append([racer.current_progress, racer.choice])
	racers.sort()
	racers.reverse()
	racers.resize(3)
	racers = racers.filter(func(element: Variant) -> bool: return element!=null)
	return racers
	
	
func top_three_text() -> String:
	# TODO Refactor this
	var first_label: String = ""
	var second_label: String = ""
	var third_label: String = ""
	var top_three_array: Array = get_top_three_array()
	
	if top_three_array.size() >= 1:
		var first_progress_percent: float = clamp(top_three_array[0][0],0.00,100.00)
		var first_progress: = str(first_progress_percent).pad_decimals(2) + "%"
		var first_title: String = top_three_array[0][1]
		first_label = first_progress + " - " + first_title
		
	if top_three_array.size() >= 2:
		var second_progress_percent: float = clamp(top_three_array[1][0],0.00,100.00)
		var second_progress: = str(second_progress_percent).pad_decimals(2) + "%"
		var second_title: String = top_three_array[1][1]
		second_label = second_progress + " - " + second_title
		
	if top_three_array.size() >= 3:
		var third_progress_percent: float = clamp(top_three_array[2][0],0.00,100.00)
		var third_progress: = str(third_progress_percent).pad_decimals(2) + "%"
		var third_title: String = top_three_array[2][1]
		third_label =  third_progress + " - " + third_title
		
	return first_label + "\n" + \
		   second_label + "\n" + \
		   third_label


func set_medal_colors() -> void:
	var top_three_array: Array = get_top_three_array()
	var first_place_racer: String = ""
	var second_place_racer: String = ""
	var third_place_racer: String = ""
	
	if top_three_array.size() >= 1: first_place_racer = top_three_array[0][1]
	if top_three_array.size() >= 2: second_place_racer = top_three_array[1][1]
	if top_three_array.size() >= 3: third_place_racer = top_three_array[2][1]
	
	for r in get_children():
		if r.choice == first_place_racer:
			r.medal_color = Color.GOLD
		elif r.choice == second_place_racer:
			r.medal_color = Color.SILVER
		elif r.choice == third_place_racer:
			r.medal_color = Color.PERU
		else:
			r.medal_color = Color.WHITE


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
		emit_signal("top_three", top_three_text())
		set_medal_colors()


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
