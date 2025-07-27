class_name Projectile
extends Area2D

@export var projectile_tip: TextureRect
@export var projectile_body: ColorRect

var target_racer: Racer
var target: Area2D

var max_speed: float = 350.00
var drag_factor: float = 0.08
var current_velocity: Vector2 = Vector2.ZERO

var projectile_type: int
const NUM_TYPES: int = 1 


func init_projectile(racer: Racer) -> void:
	target_racer = racer
	target = target_racer.projectile_collision
	projectile_type = randi_range(1, NUM_TYPES)
	target_racer.show_reticle()
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
	current_velocity = max_speed * Vector2.RIGHT.rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#look_at(target.global_position)
	#position = position.move_toward(target.global_position, max_speed * delta)
	var direction: Vector2 = global_position.direction_to(target.global_position)
	
	var desired_velocity: Vector2 = direction * max_speed
	#var previous_velocity: Vector2 = current_velocity
	var change: Vector2 = (desired_velocity - current_velocity) * drag_factor
	
	current_velocity += change
	
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _process(_delta: float) -> void:
	if !target_racer.target_reticle.visible:
		target_racer.target_reticle.show()
		


func _on_area_entered(area: Area2D) -> void:
	print ("target choice: " + str(target_racer.choice))
	print ("target: " + str(target))
	print ("entered: " + str(area))
	if area == target:
		target_racer.apply_projectile_effect(projectile_type)
		target_racer.target_reticle.hide()
		remove_projectile()
