class_name Projectile
extends Area2D

# TODO CLEAN UP THIS WHOLE THING
# LOTS OF UNNECESSARY COMPLEXITY FROM EXPERIMENTING

@export var projectile_tip: TextureRect
@export var projectile_body: ColorRect
@export var missile_sfx_launch: AudioStreamPlayer
@export var missile_sfx_cruising: AudioStreamPlayer2D
@export var missile_sfx_return: AudioStreamPlayer2D
@export var missile_sfx_explosion: AudioStreamPlayer

var explosion_scene: PackedScene = preload("res://vfx/explosion.tscn")

var target_racer: Racer
var target: Area2D

var max_speed: float = 900.00
var boost_multiplier: float = 3.0
var current_speed: float

const LAUNCH_DRAG_FACTOR: float = 0.01
const CRUISING_DRAG_FACTOR: float = 0.25
var current_drag_factor: float

var current_velocity: Vector2 = Vector2.ZERO

var dmg_multiplier: float = 0

var active: bool = false

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
			projectile_tip.self_modulate = Color.RED #DEPRECATED
			projectile_body.color = Color.RED #DEPRECATED

func remove_projectile() -> void:
	queue_free()


func signal_on_hit() -> void:
	emit_signal("on_hit", projectile_type)


func play_launch_sfx() -> void:
	missile_sfx_launch.play()
	await missile_sfx_launch.finished
	missile_sfx_cruising.play()

func spawn_explosion() -> void:
	var explosion: Explosion = explosion_scene.instantiate()
	explosion.global_position = self.global_position
	get_tree().root.add_child(explosion)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var boost_modifier: float = randf_range(1.0, 1.5)
	current_speed = max_speed * boost_multiplier * boost_modifier # Initial boost
	current_velocity = current_speed * Vector2.RIGHT.rotated(rotation)
	current_drag_factor = CRUISING_DRAG_FACTOR
	play_launch_sfx()
	await get_tree().create_timer(0.4).timeout
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# Move projectile toward target
	if active:
		if current_speed > max_speed:
			var deceleration: float = max_speed * delta * boost_multiplier / 2.0
			current_speed -= deceleration
			current_velocity = Vector2.RIGHT * current_speed
		else:
			dmg_multiplier += delta
			if missile_sfx_cruising.playing: missile_sfx_cruising.stop()
			if !missile_sfx_return.playing: missile_sfx_return.play()
			#if current_drag_factor <= CRUISING_DRAG_FACTOR:
				#current_drag_factor = lerp(current_drag_factor, CRUISING_DRAG_FACTOR, 0.005)
			var direction: Vector2 = global_position.direction_to(target.global_position)
			var desired_velocity: Vector2 = direction * current_speed
			var change: Vector2 = (desired_velocity - current_velocity) * current_drag_factor
			current_velocity += change
		position += current_velocity * delta
		look_at(global_position + current_velocity)


func _process(_delta: float) -> void:
	if !target_racer.target_crosshair.visible:
		target_racer.target_crosshair.show()


func _on_area_entered(area: Area2D) -> void:
	#print ("target choice: " + str(target_racer.choice))
	#print ("target: " + str(target))
	#print ("entered: " + str(area))
	if area == target:
		if missile_sfx_cruising.playing: missile_sfx_cruising.stop()
		if missile_sfx_return.playing: missile_sfx_return.stop()
		#missile_sfx_explosion.play()
		target_racer.apply_projectile_effect(projectile_type, dmg_multiplier)
		target_racer.target_crosshair.hide()
		target_racer.update_line()
		print("Accumulated dmg multiplier: " + str(dmg_multiplier))
		spawn_explosion()
		remove_projectile()
