extends Node


################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

@export_group("Racers")
@export var racer_scene: PackedScene
@export_range(0, 12) var number_of_racers:int = 12

var list_path = "user://movies.list"
var y_offset = 0
var movie_title_array: Array
var racing: bool = false


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func setup_race():
	# Initialize spawner
	remove_racers()
	y_offset = 0
	# Get movie title array, shuffle the array, and spawn racers
	movie_title_array = get_movie_title_array(list_path)
	movie_title_array.shuffle()
	movie_title_array.resize(number_of_racers)
	spawn_racers()
	racing = true

func remove_racers():
	for n in get_children():
		remove_child(n)
		n.queue_free()

func get_movie_title_array(path):
	var file = FileAccess.open(path,FileAccess.READ)
	var movie_list = file.get_var()
	var title_array = movie_list.split("\n")
	#print(title_array)
	return title_array

func set_title_colors(top_three_racers: Array):
	var first_place_title = top_three_racers[0][1]
	var second_place_title = top_three_racers[1][1]
	var third_place_title = top_three_racers[2][1]
	for n in get_children():
		if n.movie_title == first_place_title:
			n.place_color = Color.GOLD
		elif n.movie_title == second_place_title:
			n.place_color = Color.SILVER
		elif n.movie_title == third_place_title:
			n.place_color = Color.PERU
		else:
			n.place_color = Color.WHITE

func spawn_racers(mode: int = 1):
	for n in number_of_racers:
		var racer: Racer = racer_scene.instantiate()
		var padding = racer.padding
		# TODO add logic for:
		# if [MODE] == 1: #NORMAL
		#	racer.roll_min = 1
		# elif [MODE] == 2: #STALLING
		#	racer.roll_min = 0
		# else #PULLBACK
		#	racer.roll_min = -1
		racer.position = Vector2(0,y_offset + padding)
		racer.movie_title = movie_title_array[n]
		racer.race_end.connect(on_race_end)
		add_child(racer)
		y_offset += racer.rect_size.y + padding

func get_top_three_racers():
	var racers = []
	for racer in get_children():
		racers.append([racer.current_progress, racer.movie_title])
	racers.sort()
	racers.reverse()
	racers.resize(3)
	return racers


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#setup_race()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if racing:
		var top_three_racers: Array = get_top_three_racers()
		emit_signal("top_three", top_three_racers)
		set_title_colors(top_three_racers)


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_over
signal top_three

func on_race_end(movie_title):
	racing = false
	emit_signal("race_over", movie_title)

func _on_hud_race_start() -> void:
	setup_race()
