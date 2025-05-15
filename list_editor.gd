extends CanvasLayer

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
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		$TextEdit.text = file.get_var()


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

func _on_save_button_pressed() -> void:
	save_list()

func _on_load_button_pressed() -> void:
	load_list()

func _on_done_button_pressed() -> void:
	hide()
