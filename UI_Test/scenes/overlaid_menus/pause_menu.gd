extends PauseMenu

func _unhandled_input(event : InputEvent) -> void:
	if XMBSave.is_menu_open():
		return # Let the XMB menu handle its own navigation
	super._unhandled_input(event)

func _on_save_game_button_pressed() -> void:
	XMBSave.call_deferred("open_save_menu")

func _on_load_game_button_pressed() -> void:
	XMBSave.call_deferred("open_load_menu")
