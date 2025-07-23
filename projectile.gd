class_name Projectile
extends Node2D

var target: Racer
var projectile_type: int

const NUM_TYPES: int = 1

func init_projectile(racer: Racer) -> void:
	target = racer
	projectile_type = randi_range(1, NUM_TYPES)
	set_projectile_color()

func set_projectile_color() -> void:
	match projectile_type:
		1:
			self_modulate = Color.RED

func move_toward_target(delta: float) -> void:
	#var target_position: Vector2 = target.projectile_collision.global_position
	position.x += delta * 500 #TODO Replace with homing script


func signal_on_hit() -> void:
	emit_signal("on_hit", projectile_type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_toward_target(delta)


func _on_area_2d_area_entered(area: Area2D) -> void:
	print ("target " + str(target.projectile_collision))
	print ("entered " + str(area))
	if area == target.projectile_collision:
		target.apply_projectile_effect(projectile_type)
		queue_free()
