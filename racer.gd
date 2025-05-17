class_name Racer
extends Area2D

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################
# Add ColorRect that changes color based on roll_str
# Color broken into levels, color gets brighter/dimmer based on % within levels
# 1.0 to >= 0.75: green
# 0.75 to >= 0.10: yellow
# 0.10 to > 0: orange
# 0: red
# < 0: flashing red

# Add ColorRect progress bar that shrinks based on roll_timer.time_left



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
@export var timer_min: float = 1.0

## Maximum time between rolls
@export var timer_max: float = 8.0

@export_group("Padding")
## Padding around each racer
@export var padding: float = 5.0

@export_group("Components")
@export var rect: ColorRect
@export var line: ColorRect
@export var line_grad: TextureRect
@export var line_grad2: TextureRect
@export var roll_timer: Timer
@export var top_three_mask: TextureRect
@export var top_three_color: ColorRect

@export_group("Labels")
@export var choice_label: Label
@export var current_progress_label: Label
@export var roll_timer_wait_label: Label
@export var current_roll_label: Label

@onready var screen_size: Vector2 =  get_viewport_rect().size
@onready var rect_size: = Vector2(screen_size.x - (padding * 2), rect.size.y)
@onready var line_max_length: float = rect_size.x - (line.position.x * 2)

var choice: String = "Default"
var current_roll: int
var current_progress: float = 0.0
var racing: bool = false
var medal_color: = Color.WHITE
var roll_str: float


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################
func resize_racer() -> void:
	rect.position.x = padding
	rect.size = rect_size
	
func init_racer() -> void:
	line_grad.size.x = 0
	line_grad2.size.x = 0
	line.size.x = 0

func roll() -> int:
	return randi_range(roll_min, roll_max)
	
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
	roll_str = float(current_roll) / float(roll_max)
	current_roll_label.text = str(current_roll)

func update_current_progress(delta: float) -> void:
	current_progress += current_roll * delta * time_scale
	var clamped_progress: float = clamp(current_progress,0.00,100.00)
	current_progress_label.text = str(clamped_progress).pad_decimals(2) + "%"

func randomize_roll_timer_wait() -> void:
	roll_timer.wait_time = randf_range(timer_min,timer_max)
	
func update_roll_timer_wait() -> void:
	roll_timer_wait_label.text = str(roll_timer.time_left).pad_decimals(2)

func update_line() -> void:
	# Roll strength modulates gradient length, gradient alpha, and line intensity
	roll_str = float(current_roll) / float(roll_max)
	# LENGTHS
	# Update line and gradient length based on current progress percent
	# 	LINE
	line.size.x = current_progress * line_max_length / 100
	# 	GRADIENT
	# Gradient length fluctuates based on roll strength
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
	# GRADIENT HIGHLIGHT
	var grad2_alpha: float = clamp(roll_str, 0.5, 0.7) if roll_str >= 0.5 else 0
	var new_grad2_color: = Color.from_hsv(0.0, 0.0, 1.0, grad2_alpha)
	line_grad2.modulate = lerp(line_grad2.modulate, new_grad2_color, 0.02)

func update_medal() -> void:
		if medal_color == Color.WHITE:
			top_three_mask.hide()
		else:
			top_three_color.color = medal_color
			top_three_mask.show()

func reset_line() -> void:
	line.size.x = 0

func start_race() -> void:
	racing = true
	reset_line()
	randomize_roll_timer_wait()
	roll_timer.start()
	update_current_roll()
	
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
	update_current_roll()
	top_three_mask.hide()
	choice_label.text = choice
	update_line()
	start_race()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if racing:
		if current_progress >= 100.00:
			current_progress = 100.00
			emit_signal("race_end", choice)
			get_tree().call_group("racers", "end_race")
		#else:
		update_current_progress(delta)
		update_roll_timer_wait()
		update_medal()
		update_line()


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_end

func _on_roll_timer_timeout() -> void:
	randomize_roll_timer_wait()
	update_current_roll()
