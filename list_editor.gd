class_name ListEditor
extends CanvasLayer

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################
# Add check to see if movie.list contains enough entries
# Error message if list is blank or doesn't contain enough entries for race

################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################

var save_path = "user://movies.list"


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################

func save_list():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var($TextEdit.text)
	
func load_list():
	if !FileAccess.file_exists(save_path): create_blank_file() 
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file.get_length() < 1: create_blank_file()
	$TextEdit.text = str(file.get_var())

func create_blank_file():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var("")

################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


################################################################################
# ---------------------------------- SIGNALS --------------------------------- #
################################################################################

signal close_editor

func _on_save_button_pressed() -> void:
	save_list()

func _on_load_button_pressed() -> void:
	load_list()

func _on_done_button_pressed() -> void:
	save_list()
	emit_signal("close_editor")
	hide()
