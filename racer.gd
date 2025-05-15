#@tool
class_name Racer
extends Area2D

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################
# Add ColorRect that changes color based on roll_strength
# Color broken into levels, color gets brighter/dimmer based on % within levels
# 1.0 to >= 0.75: green
# 0.75 to >= 0.10: yellow
# 0.10 to > 0: orange
# 0: red
# < 0: flashing red

# Add ColorRect progress bar that shrinks based on $RollTimer.time_left



################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export_group("Dice")
## Number of dice to roll at once [br]
## Lower to raise chance of rolling larger numbers
@export var number_of_dice = 10 

## Lowest number on each die [br]
## Use 1 or greater for a regular race [br]
## Use 0 for a stop/start race with frequent stalling [br]
## Use -1 or less for the racers to frequently lose progress [br]
## 1=NORMAL, 0=STALLING, -1=PULLBACK
@export var roll_min = -1 

## Highest number on each die
@export var roll_max = 20

@export_group("Timer")
## Time scale applied to current_progress each tick [br]
## Recommended: 0.5 for positive roll_min, 1.0 for negative
@export_range(0.0, 2.0, 0.5) var time_scale: float = 1.0 

## Minimum time between rolls
@export var timer_min = 1

## Maximum time between rolls
@export var timer_max = 8

@export_group("Padding")
## Padding around each racer
@export var padding = 5

@onready var line = $ColorRect/Line
@onready var gradient = $ColorRect/Line/LineGradient
@onready var gradient2 = $ColorRect/Line/LineGradient2
@onready var screen_size =  get_viewport().size

#@onready var screen_size = get_window().content_scale_size
@onready var rect_size = Vector2(screen_size.x - (padding * 2), $ColorRect.size.y)
@onready var line_margin_x = $ColorRect/Line.position.x
@onready var line_max_length = rect_size.x - (line_margin_x * 2)

var movie_title: String = "Default"
var current_roll: int
var current_progress: float = 0.0
var racing: bool = false
var place_color = Color.WHITE
var roll_strength: float


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func resize_racer():
	#print("screen_size:" + str(screen_size))
	#print("rect_size: " + str(rect_size))
	#print("get_viewport().content_scale_size" + str(get_viewport().content_scale_size))
	$ColorRect.position.x = padding
	$ColorRect.size = rect_size
	
func init_racer():
	gradient.size.x = 0
	gradient2.size.x = 0
	line.size.x = 0

func roll() -> int:
	return randi_range(roll_min, roll_max)
	
func lowest_roll(rolls):
	var roll_array = []
	for n in rolls:
		roll_array.append(roll())
	return roll_array.min()
	
func highest_roll(rolls):
	var roll_array = []
	for n in rolls:
		roll_array.append(roll())
	return roll_array.max()

func update_current_roll():
	current_roll = lowest_roll(number_of_dice)
	roll_strength = float(current_roll) / float(roll_max)
	$ColorRect/CurrentRoll.text = str(current_roll)

func update_current_progress(delta):
	current_progress += current_roll * delta * time_scale
	var clamped_progress = clamp(current_progress,0.00,100.00)
	$ColorRect/CurrentProgress.text = str(clamped_progress).pad_decimals(2) + "%"

func randomize_roll_timer_wait():
	$RollTimer.wait_time = randf_range(timer_min,timer_max)
	
func update_roll_timer_wait():
	$ColorRect/RollTimerWait.text = str($RollTimer.time_left).pad_decimals(2)

func update_line():
	# Roll strength modulates gradient length, gradient alpha, and line intensity
	roll_strength = float(current_roll) / float(roll_max)
	
	# Update line and gradient length based on current progress percent
	# LINE
	line.size.x = current_progress * line_max_length / 100
	# GRADIENT
	# Gradient length fluctuates based on roll strength
	var gradient_new_size_x = line.size.x * clamp(roll_strength,0.7,1.0)
	gradient.size.x = lerp(gradient.size.x, gradient_new_size_x,0.02)
	gradient.position.x = ceil(line.size.x - gradient.size.x)
	# GRADIENT HIGHLIGHT
	var gradient2_size_max = line_max_length * 0.005
	var gradient2_new_size_x = float(clamp(line.size.x, line.size.x, gradient2_size_max))
	gradient2.size.x = lerp(gradient2.size.x, gradient2_new_size_x,0.02)
	gradient2.position.x = ceil(line.size.x - gradient2.size.x)
	
	# Update line color based on current progress percent
	# Changes from red to green as the race progresses
	var hue = clamp(current_progress * 0.003,0.0,1.0)
	# LINE
	var line_value = lerp (line.color.v, clamp(roll_strength*2, 0.6, 0.9), 0.6)
	var new_line_color = Color.from_hsv(hue, 0.95, line_value)
	line.color = lerp(line.color, new_line_color, 0.06)
	# GRADIENT
	var gradient_hue = hue + 0.03
	var gradient_alpha = clamp(roll_strength*2, 0.1, 1.0)
	var new_gradient_color = Color.from_hsv(gradient_hue, 1.0, 1.0, gradient_alpha)
	gradient.modulate = lerp(gradient.modulate, new_gradient_color, 0.03)
	# GRADIENT HIGHLIGHT
	var gradient2_alpha = clamp(roll_strength, 0.5, 0.7) if roll_strength >= 0.5 else 0
	var new_gradient2_color = Color.from_hsv(0.0, 0.0, 1.0, gradient2_alpha)
	gradient2.modulate = lerp(gradient2.modulate, new_gradient2_color, 0.02)

func update_place():
		#$ColorRect/MovieTitle.modulate = place_color
		if place_color == Color.WHITE:
			$ColorRect/TopThreeMask.hide()
		else:
			$ColorRect/TopThreeMask/TopThreeColor.color = place_color
			$ColorRect/TopThreeMask.show()

func reset_line():
	line.size.x = 0

func start_race():
	racing = true
	reset_line()
	randomize_roll_timer_wait()
	$RollTimer.start()
	update_current_roll()
	
func end_race():
	racing = false
	$RollTimer.stop()
	update_line()
	
	
################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize_racer()
	init_racer()
	update_current_roll()
	$ColorRect/TopThreeMask.hide()
	$ColorRect/MovieTitle.text = movie_title
	update_line()
	start_race()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if racing:
		if current_progress >= 100.00:
			current_progress = 100.00
			emit_signal("race_end", movie_title)
			get_tree().call_group("racers", "end_race")
		#else:
		update_current_progress(delta)
		update_roll_timer_wait()
		update_place()
		update_line()


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_end

func _on_roll_timer_timeout() -> void:
	randomize_roll_timer_wait()
	update_current_roll()
