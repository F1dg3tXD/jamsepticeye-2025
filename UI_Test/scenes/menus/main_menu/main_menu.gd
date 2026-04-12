extends MainMenu

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	XMBSave.default_game_scene_path = "res://maps/ct_0.tscn" # Default start level

func _on_load_game_button_pressed() -> void:
	XMBSave.open_load_menu()
