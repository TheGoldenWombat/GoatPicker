class_name RollIndicator
extends Control

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export var indicator_color: ColorRect
@export var current_roll_label: Label

var red: Color = Color.from_hsv(0.0, 1.0, 1.0)
var current_roll: int = 0
var roll_strength: float = 0.0
var current_color: Color = red
var new_color: Color = red

################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func set_current_roll(cur_roll: int) -> void:
	current_roll = cur_roll


func set_roll_strength(roll_str: float) -> void:
	roll_strength = roll_str


func set_default_indicator_color() -> void:
	current_color = red
	current_color.v = 0.1
	new_color = red
	new_color.v = 0.4
	indicator_color.self_modulate = current_color


func get_indicator_color() -> Color:
	var hue: float = clamp(roll_strength * 0.7,0.0,0.5)
	var value: float = clamp (roll_strength * 2 + 0.3, 0.0, 1.0)
	return Color.from_hsv(hue, 1.0, value)


func get_new_indicator_color() -> void:
	#if current_roll_label.hidden: current_roll_label.show()
	if roll_strength >= 0.0:
		new_color = get_indicator_color()
	else: # DIM RED
		new_color = red
		new_color.v = 0.1
	
	
func update_indicator_color() -> void:
	current_color = lerp(current_color, new_color, 0.02)
	indicator_color.self_modulate = current_color


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_default_indicator_color()
	current_roll_label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	current_roll_label.text = str(current_roll)
	update_indicator_color()
