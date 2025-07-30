class_name Projectile
extends Area2D

@export var projectile_tip: TextureRect
@export var projectile_body: ColorRect

var target_racer: Racer
var target: Area2D

var max_speed: float = 500.00
var boost_multiplier: float = 5.0
var current_speed: float

const LAUNCH_DRAG_FACTOR: float = 0.01
const CRUISING_DRAG_FACTOR: float = 0.25
var current_drag_factor: float

var current_velocity: Vector2 = Vector2.ZERO

var projectile_type: int
const NUM_TYPES: int = 1 


func init_projectile(racer: Racer) -> void:
	target_racer = racer
	target = target_racer.projectile_collision
	projectile_type = randi_range(1, NUM_TYPES)
	target_racer.show_crosshair()
	set_projectile_color()
	

func set_projectile_color() -> void:
	match projectile_type:
		1:
			projectile_tip.self_modulate = Color.RED
			projectile_body.color = Color.RED

func remove_projectile() -> void:
	queue_free()

func signal_on_hit() -> void:
	emit_signal("on_hit", projectile_type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_speed = max_speed * boost_multiplier # Initial boost
	current_velocity = current_speed * Vector2.RIGHT.rotated(rotation)
	current_drag_factor = LAUNCH_DRAG_FACTOR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	# Move projectile toward target
	if current_speed > max_speed:
		var deceleration: float = max_speed * delta * boost_multiplier / 2.5
		current_speed -= deceleration
		
	if current_speed <= max_speed * (boost_multiplier * 0.66):
		if current_drag_factor <= CRUISING_DRAG_FACTOR:
			current_drag_factor = lerp(current_drag_factor, CRUISING_DRAG_FACTOR, 0.005)
			print(current_drag_factor)
		var direction: Vector2 = global_position.direction_to(target.global_position)
		var desired_velocity: Vector2 = direction * current_speed
		var change: Vector2 = (desired_velocity - current_velocity) * current_drag_factor
		current_velocity += change
	else:
		current_velocity = Vector2.RIGHT * current_speed
	position += current_velocity * delta
	look_at(global_position + current_velocity)


func _process(_delta: float) -> void:
	if !target_racer.target_crosshair.visible:
		target_racer.target_crosshair.show()
		


func _on_area_entered(area: Area2D) -> void:
	print ("target choice: " + str(target_racer.choice))
	print ("target: " + str(target))
	print ("entered: " + str(area))
	if area == target:
		target_racer.apply_projectile_effect(projectile_type)
		target_racer.target_crosshair.hide()
		target_racer.update_line()
		remove_projectile()
