@tool
extends ScrollingCredits

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_button_pressed() -> void:
	SceneLoader.load_scene("res://UI_Test/scenes/opening/opening_with_logo.tscn")
