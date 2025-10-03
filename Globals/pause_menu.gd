extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var master_options_menu: PaginatedTabContainer = %MasterOptionsMenu


func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func open() -> void:
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	resume_button.grab_focus()

func close() -> void:
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	close()
	
func _on_options_button_pressed() -> void:
	# Hide pause menu buttons, show options menu
	$VBoxContainer.visible = false
	master_options_menu.visible = true

	# Give focus to the first option tab or back button
	var first_focusable = master_options_menu.get_child(0)
	if first_focusable and first_focusable is Control:
		first_focusable.grab_focus()

# Call this when the options menu wants to return to pause menu
func return_from_options() -> void:
	master_options_menu.visible = false
	$VBoxContainer.visible = true
	options_button.grab_focus()
