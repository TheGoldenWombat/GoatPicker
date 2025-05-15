extends CanvasLayer

################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MovieAnnouncement.hide()
	$TopThree.hide()
	$ListEditor.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal race_start

func _on_racer_spawn_race_over(movie_title) -> void:
	$MovieAnnouncement.text = "Tonight's movie is: \n" + movie_title
	$MovieAnnouncement.show()
	$StartButton.show()
	$EditListButton.show()
	$TopThree.show()

func _on_racer_spawn_top_three(top_three) -> void:
	var first_progress = str(clamp(top_three[0][0],0.00,100.00)).pad_decimals(2) + "%"
	var first_title = top_three[0][1]
	var second_progress = str(clamp(top_three[1][0],0.00,100.00)).pad_decimals(2) + "%"
	var second_title = top_three[1][1]
	var third_progress = str(clamp(top_three[2][0],0.00,100.00)).pad_decimals(2) + "%"
	var third_title = top_three[2][1]
	$TopThree.text = first_progress + " - " + first_title + "\n" + \
					  second_progress + " - " + second_title + "\n" + \
					  third_progress + " - " + third_title

func _on_start_button_pressed() -> void:
	$MovieAnnouncement.hide()
	$StartButton.hide()
	$EditListButton.hide()
	$TopThree.show()
	emit_signal("race_start")


func _on_edit_list_button_pressed() -> void:
	$ListEditor.show()
