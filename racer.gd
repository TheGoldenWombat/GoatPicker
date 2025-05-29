class_name Racer
extends Node2D

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################

# Break out the line into it's own seperate scene called ProgressMeter

# Add ColorRect that changes color based on roll_str
# Maybe color the RollTimerMeter instead of a ColorRect? Need to test.
# Blink at a rate of roll / roll_max * x; higher = faster blink
# Color brighter at higher rolls
# 1.0 to >= 0.3: green
# 0.3 to >= 0.1: yellow
# 0.1 to > 0.0: orange
# 0.0: solid red
# < 0.0: flashing red


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export_group("Dice")
## Number of dice to roll at once [br]
## Lower to raise chance of rolling larger numbers
@export var number_of_dice: int = 10

## Lowest number on each die [br]
## Use 1 or greater for a regular race [br]
## Use 0 for a stop/start race with frequent stalling [br]
## Use -1 or less for the racers to frequently lose progress [br]
## 1=NORMAL, 0=STALLING, -1=PULLBACK
@export var roll_min: int = -1 

## Highest number on each die
@export var roll_max: int = 20


@export_group("Timer")
## Time scale applied to current_progress each tick [br]
## Recommended: 0.5 for positive roll_min, 1.0 for negative
@export_range(0.0, 2.0, 0.5) var time_scale: float = 1.0 

## Minimum time between rolls
@export var timer_min: float = 2.0

## Maximum time between rolls
@export var timer_max: float = 8.0


@export_group("Padding")
## Padding around each racer
@export var outside_padding: float = 5.0
@export var end_padding: float = 15.0


@export_group("Components")
@export var rect: ColorRect
@export var line: ColorRect
@export var line_grad: TextureRect
@export var line_grad2: TextureRect
@export var roll_timer: Timer
@export var roll_timer_meter: RollTimerMeter
@export var top_three_mask: TextureRect
@export var top_three_color: ColorRect
@export var roll_indicator: RollIndicator
@export var combo_controller: ComboController


@export_group("Labels")
@export var choice_label: Label
@export var current_progress_label: Label
@export var roll_timer_wait_label: Label
@export var current_roll_label: Label


@onready var screen_size: Vector2 =  get_viewport_rect().size
@onready var rect_size: = Vector2(screen_size.x - (outside_padding * 2), rect.size.y)
@onready var line_max_length: float = rect_size.x - line.position.x - end_padding
@onready var choices_array: Array = get_choices_array(list_path)

var choice: String = "Default"
var previous_roll: int
var current_roll: int = 0
var current_progress: float = 0.0
var racing: bool = false
var randomizing_choice:bool = false
var medal_color: = Color.WHITE
var roll_str: float
var meter_percent: float
var list_path: String = "user://choices.list"
var reel_timer: float = 0


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func resize_racer() -> void:
	rect.position.x = outside_padding
	rect.size = rect_size


func init_racer() -> void:
	reset_line()
	top_three_mask.hide()
	#current_progress_label.hide()
	choice_label.text = choice


func reset_line() -> void:
	line.size.x = 0
	line_grad.size.x = 0
	line_grad2.size.x = 0


func roll() -> int:
	var rolled: int = randi_range(roll_min, roll_max)
	return rolled


func combo_check() -> void:
	var current_combo: int = combo_controller.current_combo
	if current_roll == previous_roll:
		combo_controller.combo()
	else:
		if current_combo > 2:
			current_roll = current_roll * current_combo
			combo_controller.combo_breaker()
		else:
			combo_controller.reset_combo()


func lowest_roll(rolls: int) -> int:
	var roll_array: Array = []
	for n in rolls:
		roll_array.append(roll())
	return roll_array.min()


func highest_roll(rolls: int) -> int:
	var roll_array: Array = []
	for n in rolls:
		roll_array.append(roll())
	return roll_array.max()


func update_current_roll() -> void:
	current_roll = lowest_roll(number_of_dice)
	roll_str = get_roll_str()
	roll_indicator.set_roll_strength(roll_str)
	roll_indicator.set_current_roll(current_roll)
	roll_indicator.get_new_indicator_color()
	current_roll_label.text = str(current_roll)


func update_current_progress(delta: float) -> void:
	var combo_bonus: float = 1 + (combo_controller.current_combo * 0.1)
	current_progress += current_roll * delta * time_scale * combo_bonus
	current_progress = clamp(current_progress,0.00,100.00)
	current_progress_label.text = str(current_progress).pad_decimals(2) + "%"


func randomize_roll_timer_wait() -> void:
	roll_timer.wait_time = randf_range(timer_min,timer_max)
	roll_timer.start()


func update_roll_timer_text() -> void:
	roll_timer_wait_label.text = str(roll_timer.time_left).pad_decimals(2)


func update_roll_timer_meter() -> void:
	meter_percent = roll_timer.time_left / roll_timer.wait_time
	roll_timer_meter.update_meter(meter_percent)


func get_roll_str() -> float:
	return float(current_roll) / float(roll_max)


func update_line() -> void:
	# TODO Refactor this
	# Roll strength modulates gradient length, gradient alpha, and line intensity
	roll_str = get_roll_str()
	
	# LENGTHS
	# Update line and gradient length based on current progress percent
	# 	LINE
	line.size.x = current_progress * line_max_length / 100
	# 	GRADIENT
	# 	Gradient length fluctuates based on roll strength
	var grad_new_size_x: float = line.size.x/4 * clamp(roll_str,0.7,1.0)
	line_grad.size.x = lerp(line_grad.size.x, grad_new_size_x,0.02)
	line_grad.position.x = ceil(line.size.x - line_grad.size.x)
	# 	GRADIENT HIGHLIGHT
	var grad2_size_max: float = line_max_length * 0.005
	var grad2_new_size_x: = float(clamp(line.size.x, line.size.x, grad2_size_max))
	line_grad2.size.x = lerp(line_grad2.size.x, grad2_new_size_x,0.02)
	line_grad2.position.x = ceil(line.size.x - line_grad2.size.x)
	
	# COLORS
	# Update line color based on current progress percent
	# Changes from red to green as the race progresses
	var hue: float = clamp(current_progress * 0.003,0.0,1.0)
	# 	LINE
	var line_value: float = lerp (line.color.v, clamp(roll_str*2, 0.6, 0.9), 0.6)
	var new_line_color: = Color.from_hsv(hue, 0.95, line_value)
	line.color = lerp(line.color, new_line_color, 0.06)
	# 	GRADIENT
	var grad_hue: float = hue + 0.03
	var grad_alpha: float = clamp(roll_str*2, 0.1, 1.0)
	var new_grad_color: = Color.from_hsv(grad_hue, 1.0, 1.0, grad_alpha)
	line_grad.modulate = lerp(line_grad.modulate, new_grad_color, 0.03)
	# 	GRADIENT HIGHLIGHT
	var grad2_alpha: float = clamp(roll_str, 0.5, 0.7) if roll_str >= 0.5 else 0
	var new_grad2_color: = Color.from_hsv(0.0, 0.0, 1.0, grad2_alpha)
	line_grad2.modulate = lerp(line_grad2.modulate, new_grad2_color, 0.02)


# TODO Revisit this at some point
func update_medal() -> void:
	pass
	#if medal_color == Color.WHITE:
		#top_three_mask.hide()
	#else:
		#top_three_color.color = medal_color
		#top_three_mask.show()


func get_choices_array(path: String) -> Array:
	var file: = FileAccess.open(path,FileAccess.READ)
	var choices: String = file.get_var()
	var array: Array = choices.split("\n")
	#Filter null and blanks
	array = array.filter(func(element: Variant) -> bool: return element!=null)
	array = array.filter(func(element: Variant) -> bool: return element!="")
	return array


func start_race() -> void:
	racing = true
	#current_progress_label.show()
	reset_line()
	randomize_roll_timer_wait()
	roll_timer.start()
	update_current_roll()


func check_for_winner() -> void:
	if current_progress >= 100.00:
		current_progress = 100.00
		emit_signal("race_end", choice)
		get_tree().call_group("racers", "end_race")


func end_race() -> void:
	racing = false
	roll_timer.stop()
	update_line()


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize_racer()
	init_racer()
	update_line()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if racing:
		check_for_winner()
		update_current_progress(delta)
		update_roll_timer_text()
		update_roll_timer_meter()
		update_medal()
		update_line()
	if randomizing_choice:
		if reel_timer <= 0:
			var new_choice: String = choices_array.pick_random()
			while new_choice == choice_label.text:
				new_choice = choices_array.pick_random()
			choice_label.text = new_choice
			reel_timer = 0.08
		else:
			reel_timer -= delta


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_end


func _on_roll_timer_timeout() -> void:
	randomize_roll_timer_wait()
	update_current_roll()
	combo_check()
	previous_roll = current_roll
	
