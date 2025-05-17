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
var default_list_path: String = "res://default_choices.txt"
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
	var choices: String = str(file.get_var())
	if choices.length() < 1:
		create_default_file()
		file = FileAccess.open(save_path, FileAccess.READ) #Reload file
		choices = str(file.get_var())
	text_box.text = choices

func create_default_file() -> void:
	var file: = FileAccess.open(save_path,FileAccess.WRITE)
	var default_list: = FileAccess.open(default_list_path, FileAccess.READ)
	var default_choices: String = default_list.get_as_text()
	print(default_choices)
	file.store_var(default_choices)


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
