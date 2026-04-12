extends Node

var last_checkpoint: Node3D = null
var default_spawn: NodePath = "/root/CT_0/DefaultSpawn" # put your scene’s default spawn here

var activated_objects: Array[String] = []

func _ready():
	XMBSave.register_save_adapter(self)

func capture_save_state() -> Dictionary:
	var player = get_tree().get_first_node_in_group("player_pawn")
	var state = {
		"activated_objects": activated_objects.duplicate()
	}
	
	if player:
		state["player_pos"] = {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"z": player.global_position.z
		}
		state["player_rot"] = {
			"x": player.global_rotation.x,
			"y": player.global_rotation.y,
			"z": player.global_rotation.z
		}
		state["player_crouching"] = player.get("is_crouching") if "is_crouching" in player else false

	if last_checkpoint:
		state["last_checkpoint_path"] = str(get_tree().current_scene.get_path_to(last_checkpoint))
	
	return state

func apply_save_state(save_data: Dictionary) -> void:
	var state = save_data.get("state", {})
	activated_objects = Array(state.get("activated_objects", []), TYPE_STRING, &"", null)
	
	# We use a small delay to ensure the scene tree has settled and groups are updated
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player_pawn")
	if player and "player_pos" in state:
		var pos = state["player_pos"]
		player.global_position = Vector3(pos.x, pos.y, pos.z)
		var rot = state["player_rot"]
		player.global_rotation = Vector3(rot.x, rot.y, rot.z)
		if "player_crouching" in state:
			if state["player_crouching"] and player.has_method("start_crouch"):
				player.start_crouch()
			elif not state["player_crouching"] and player.has_method("stop_crouch"):
				player.stop_crouch()

	if "last_checkpoint_path" in state:
		var path = state["last_checkpoint_path"]
		var checkpoint = get_tree().current_scene.get_node_or_null(path)
		if checkpoint:
			last_checkpoint = checkpoint

	# Re-apply activated state to world objects
	for obj_path in activated_objects:
		var obj = get_tree().current_scene.get_node_or_null(obj_path)
		if obj and obj.has_method("apply_activated_state"):
			obj.apply_activated_state()

func register_activation(obj: Node):
	var path = str(get_tree().current_scene.get_path_to(obj))
	if not activated_objects.has(path):
		activated_objects.append(path)
