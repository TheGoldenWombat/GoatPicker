class_name ListEditor
extends CanvasLayer

################################################################################
# ----------------------------------- TODO ----------------------------------- #
################################################################################
# Add check to see if choices.list contains enough entries
# Error message if list is blank or doesn't contain enough entries for race

################################################################################
# --------------------------------- VARIABLES -------------------------------- #
################################################################################
@export var text_box: TextEdit
var save_path: String = "user://choices.list"


################################################################################
# --------------------------------- FUNCTIONS -------------------------------- #
################################################################################
func save_list() -> void:
	var file: = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(text_box.text)
	
func load_list() -> void:
	if !FileAccess.file_exists(save_path): create_default_file() 
	var file: = FileAccess.open(save_path, FileAccess.READ)
	if file.get_length() < 1: create_default_file()
	text_box.text = str(file.get_var())

func create_default_file() -> void:
	var file: = FileAccess.open(save_path,FileAccess.WRITE)
	# TODO Add default list of at least 12 choice
	file.store_var("")


################################################################################
# --------------------------------- PROCESSES -------------------------------- #
################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
