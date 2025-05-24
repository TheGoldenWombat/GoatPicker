class_name RollTimerMeter
extends Control


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################
@export var meter: ColorRect
@onready var meter_max: float = meter.size.y
var meter_current: float = 0.0


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################
func update_meter(meter_percent: float) -> void:
	meter_current = meter_max * meter_percent
	meter.size.y = meter_current


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#meter.size.y = 0
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
