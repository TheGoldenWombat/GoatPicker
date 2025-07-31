class_name Explosion
extends Node2D

@export var missile_explosion_sfx: AudioStreamPlayer

func missile_explosion() -> void:
	missile_explosion_sfx.play()
	await missile_explosion_sfx.finished
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	missile_explosion()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
