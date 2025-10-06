extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_button_large_5_pressed_changed(_pressed: bool) -> void:
	self.freeze = false
