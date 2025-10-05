extends Node3D
@onready var area_3d: Area3D = $Area3D
@export var next_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player_pawn"):
		print("Loading next level...")
		load_next_level()

func load_next_level() -> void:
	if next_scene == "":
		push_warning("DoorExit: no next scene path assigned.")
		return

	if Engine.has_singleton("SceneLoader"):
		var scene_loader = Engine.get_singleton("SceneLoader")
		scene_loader.load_scene(next_scene)
	else:
		push_warning("DoorExit: SceneLoader singleton not found. Falling back to default change_scene.")
		get_tree().change_scene_to_file(next_scene)
