class_name ComboController
extends Control

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################



################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export var combo_counter: Label
@export var combo_alert: Sprite2D
@export var combo_3: AudioStreamPlayer
@export var combo_4: AudioStreamPlayer
@export var combo_5: AudioStreamPlayer
@export var combo_6: AudioStreamPlayer
@export var combo_7: AudioStreamPlayer
@export var combo_8: AudioStreamPlayer
@export var combo_9: AudioStreamPlayer
@export var combo_10: AudioStreamPlayer
@export var combo_breaker_alert: Sprite2D
@export var combo_breaker_sfx: AudioStreamPlayer

var current_combo: int = 0

const ALERT_ROTATE_MIN = -10
const ALERT_ROTATE_MAX = 25


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func init_combo_controller() -> void:
	combo_counter.hide()
	combo_alert.hide()
	combo_breaker_alert.hide()


func combo() -> void:
	current_combo += 1
	combo_counter.text = "x" + str(current_combo)
	spawn_combo_alert()
	if combo_counter.hidden: combo_counter.show()


func reset_combo() -> void:
	current_combo = 0
	combo_counter.hide()


func combo_breaker() -> void:
	current_combo = 0
	combo_counter.hide()
	spawn_combo_breaker_alert()


func spawn_combo_alert() -> void:
	combo_alert.rotation_degrees = randf_range(ALERT_ROTATE_MIN, ALERT_ROTATE_MAX)
	combo_alert.show()
	play_combo_sfx()
	await get_tree().create_timer(1).timeout
	combo_alert.hide()


func spawn_combo_breaker_alert() -> void:
	combo_breaker_alert.show()
	combo_breaker_sfx.play()
	await get_tree().create_timer(3).timeout
	combo_breaker_alert.hide()


func play_combo_sfx() -> void:
	match current_combo:
		3: combo_3.play()
		4: combo_4.play()
		5: combo_5.play()
		6: combo_6.play()
		7: combo_7.play()
		8: combo_8.play()
		9: combo_9.play()
		10: combo_10.play()



################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_combo_controller()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
