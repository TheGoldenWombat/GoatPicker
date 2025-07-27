class_name RaceScene
extends Control

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################

# Add top 3 leaderboard
# Add abort button
#  - Abort button removes all racers
# Modify Racers to spawn inside of a grid container


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export_group("Racers")
@export var racers_container: VBoxContainer
@export var racers_margin: MarginContainer
@export_range(0, 12) var max_racers: int = 12

@export_group("SFX")
@export var sounds: Node
@export var sfx_reel_spin: AudioStreamPlayer
@export var sfx_reel_stop: AudioStreamPlayer
@export var sfx_trumpet: AudioStreamPlayer
@export var sfx_gunshot: AudioStreamPlayer
@export var race_music: AudioStreamPlayer
@export var race_end_jingle: AudioStreamPlayer
@export var race_end_music: AudioStreamPlayer

@export_group("UI")
@export var leaderboard_label: Label
@export var pause_button: Button

var racer_scene: PackedScene = preload("res://racer.tscn")
var number_of_racers: int = max_racers
var list_path: String = "user://choices.list"
var y_offset: float = 0.0
var choices_array: Array
var racing: bool = false
var medal_delay: bool = true

var debug: bool = true

# TOGGLES
var combos_enabled: bool = false
var attacks_enabled: bool = false


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

## Initializes spawner properties, gets the list of choices, and spawns the racers
func setup_race(mode: int) -> void:
	leaderboard_label.hide()
	pause_button.hide()
	# Initialize spawner
	stop_all_audio()
	remove_racers()
	y_offset = 0
	# Get choices array, adjust # of racers, shuffle the array, and spawn racers
	set_choices_array()
	choices_array.shuffle()
	choices_array.resize(number_of_racers)
	await spawn_racers(mode)
	start_race()


func set_number_of_racers() -> void:
	var number_of_choices: int = choices_array.size()
	number_of_racers = max_racers
	if number_of_choices < number_of_racers: 
		number_of_racers = number_of_choices


func get_number_of_racers() -> int:
	set_choices_array()
	set_number_of_racers()
	return number_of_racers


## Removes all racers from racer_spawn
func remove_racers() -> void:
	for node: Node in racers_container.get_children():
		if node is Racer:
			#remove_child(node)
			node.queue_free()


func set_choices_array() -> void:
	var file: FileAccess = FileAccess.open(list_path,FileAccess.READ)
	var choices: String = file.get_var()
	var array: Array = choices.split("\n")
	#Filter null and blanks
	array = array.filter(func(element: Variant) -> bool: return element!=null)
	array = array.filter(func(element: Variant) -> bool: return element!="")
	choices_array = array


## Get list of choices from choices.list and read them into an array
func get_choices_array() -> Array:
	set_choices_array()
	return choices_array


## Spawns racers with three possible race modes: [br]
##   Mode 1 - NORMAL [br]
##   - The racers constantly move forward [br]
##   - Rolls dice between 1 and racer.roll_max [br]
##   Mode 2 - STALLING [br]
##   - The racers will frequently stall [br]
##   - Rolls dice between 0 and racer.roll_max [br]
##   Mode 3 - PULLBACK [br]
##   - The racers will frequently stall and creep backward [br]
##   - Rolls dice between -1 and racer.roll_max [br]
func spawn_racers(mode: int = 1) -> void:
	for i: int in number_of_racers:
		var racer: Racer = racer_scene.instantiate()
		var original_time_scale: float = racer.time_scale
		# Set roll_min based on mode
		if mode == 1: #NORMAL
			racer.roll_min = 1
			racer.time_scale = racer.time_scale * 0.5
		elif mode == 2: #STALLING
			racer.roll_min = 0
		else: #PULLBACK
			racer.roll_min = -1
		
		var right_margin: float = racers_margin.theme.get_constant("margin_right", "MarginContainer")
		var left_margin: float = racers_margin.theme.get_constant("margin_left", "MarginContainer")
		racer.end_padding += left_margin + right_margin
		racer.set_line_max_length()
		racer.combos_enabled = combos_enabled
		racer.attacks_enabled = attacks_enabled
		
		racer.race_end.connect(on_race_end)
		
		racer.randomizing_choice = true
		racers_container.add_child(racer)
		sfx_reel_spin.play(randf_range(0.0,6.0))
		#await get_tree().create_timer(0.1).timeout # For debugging
		var timer_length: float = 1.5 / original_time_scale
		if debug == true: timer_length = 0.3
		await get_tree().create_timer(timer_length).timeout
		sfx_reel_spin.stop()
		sfx_reel_stop.play()
		racer.randomizing_choice = false
		
		racer.choice = choices_array[i]
		racer.init_racer()
		
		await get_tree().create_timer(0.3).timeout


func start_race() -> void:
	await sfx_race_start_fanfare()
	race_music.play()
	racing = true
	get_tree().call_group("racers", "start_race")
	leaderboard_label.show()
	pause_button.show()


func sfx_race_start_fanfare() -> void:
	sfx_trumpet.play()
	await sfx_trumpet.finished
	sfx_gunshot.play()


func sfx_race_end() -> void:
	if race_music.playing: race_music.stop()
	race_end_jingle.play()
	await race_end_jingle.finished
	race_end_music.play()


func stop_all_audio() -> void:
	for n: Node in sounds.get_children():
		if n is AudioStreamPlayer && n.playing:
			n.stop()


func get_racers_progress() -> Array:
	var racers: Array = []
	for racer: Node in racers_container.get_children():
		if racer is Racer:
			racers.append([racer.current_progress, racer.choice])
	return racers


## Get array of the top three racers, or fewer if there aren't three racers total
func get_top_three_array() -> Array:
	var racers: Array = get_racers_progress()
	#print(racers)
	racers.sort()
	racers.reverse()
	racers.resize(3)
	racers = racers.filter(func(element: Variant) -> bool: return element!=null)
	return racers

## Generates text to be sent to the top three leaderboard in the HUD
func get_leaderboard_text() -> String:
	# TODO Refactor this
	var first_label: String = ""
	var second_label: String = ""
	var third_label: String = ""
	var top_three_array: Array = get_top_three_array()
	
	if top_three_array.size() >= 1:
		var first_progress_percent: float = clamp(top_three_array[0][0],0.00,100.00)
		var first_progress: String = str(first_progress_percent).pad_decimals(2) + "%"
		var first_title: String = top_three_array[0][1]
		first_label = first_progress + " - " + first_title
		
	if top_three_array.size() >= 2:
		var second_progress_percent: float = clamp(top_three_array[1][0],0.00,100.00)
		var second_progress: String = str(second_progress_percent).pad_decimals(2) + "%"
		var second_title: String = top_three_array[1][1]
		second_label = second_progress + " - " + second_title
		
	if top_three_array.size() >= 3:
		var third_progress_percent: float = clamp(top_three_array[2][0],0.00,100.00)
		var third_progress: String = str(third_progress_percent).pad_decimals(2) + "%"
		var third_title: String = top_three_array[2][1]
		third_label =  third_progress + " - " + third_title
		
	return first_label + "\n" + \
		   second_label + "\n" + \
		   third_label


## Sets the medal colors next to the top three racers
func set_medal_colors() -> void:
	var top_three_array: Array = get_top_three_array()
	var first_place_racer: String = ""
	var second_place_racer: String = ""
	var third_place_racer: String = ""
	
	if top_three_array.size() >= 1: first_place_racer = top_three_array[0][1]
	if top_three_array.size() >= 2: second_place_racer = top_three_array[1][1]
	if top_three_array.size() >= 3: third_place_racer = top_three_array[2][1]
	
	for n: Node in racers_container.get_children():
		if n is Racer:
			if n.choice == first_place_racer: n.medal_color = Color.GOLD
			elif n.choice == second_place_racer: n.medal_color = Color.SILVER
			elif n.choice == third_place_racer: n.medal_color = Color.PERU
			else: n.medal_color = Color.WHITE




################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#setup_race()
	leaderboard_label.text = ""
	pause_button.hide()
	set_choices_array()
	set_number_of_racers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if racing:
		leaderboard_label.text = get_leaderboard_text()
		if medal_delay:
			await get_tree().create_timer(0.3).timeout
			medal_delay = false
		else:
			set_medal_colors()


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_end
signal race_pause
#signal show_top_three
#signal top_three


## Stops the race and emits a signal that contains the name of the winner
func on_race_end(choice: String) -> void:
	racing = false
	emit_signal("race_end", choice)
	get_tree().call_group("projectiles", "remove_projectile")
	print("race_end signal relayed")
	sfx_race_end()
	pause_button.hide()


## Starts the race using the specified mode
func _on_hud_race_start(mode: int) -> void:
	setup_race(mode)


## Clears the racers when the main menu is initialized
func _on_hud_clear_racers() -> void:
	racing = false
	remove_racers()


func _on_pause_button_pressed() -> void:
	pause_button.hide()
	racing = false
	race_music.stream_paused = true
	get_tree().call_group("racers", "pause_race")
	emit_signal("race_pause")


func _on_post_race_menu_resume_race() -> void:
	pause_button.show()
	racing = true
	race_music.stream_paused = false
	get_tree().call_group("racers", "resume_race")


func _on_post_race_menu_restart_race_button_pressed() -> void:
	stop_all_audio()
	leaderboard_label.hide()
	get_tree().call_group("racers", "init_racer")
	start_race()
