extends Node3D
class_name AudioTrigger

@export var sound: AudioStream
@export var speaker: NodePath         # optional: link a specific speaker in the inspector
@export var bus_name: String = "Voices"

@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	if not area_3d:
		push_warning("Area3D not found under AudioTrigger node.")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player_pawn"):
		return

	if not sound:
		push_warning("No sound assigned to AudioTrigger.")
		return

	# Stop any audio currently playing on the target bus
	_stop_audio_on_bus(bus_name)

	# Try to play on the explicitly linked speaker first
	var target_speaker: Node = null
	if speaker != NodePath(""):
		target_speaker = get_node_or_null(speaker)

	# If linked speaker exists and exposes play_sound(sound, bus_name), call it
	if target_speaker and target_speaker.has_method("play_sound"):
		target_speaker.call("play_sound", sound, bus_name)
	else:
		# Fallback: find the nearest Speaker node that implements play_sound()
		var nearest := _find_nearest_speaker()
		if nearest:
			nearest.play_sound(sound, bus_name)
		else:
			push_warning("No speaker found for AudioTrigger '" + str(name) + "'; audio will not play.")

	# Prevent re-triggering this trigger (one-shot)
	area_3d.set_deferred("monitoring", false)


func _stop_audio_on_bus(target_bus_name: String) -> void:
	# Walk the current scene tree and stop any AudioStreamPlayer/AudioStreamPlayer3D on the same bus.
	var root = get_tree().current_scene
	if root == null:
		# fallback
		root = get_tree().root

	var stack: Array = [root]
	while stack.size() > 0:
		var node = stack.pop_back()
		# Stop players on the bus
		if node is AudioStreamPlayer or node is AudioStreamPlayer3D:
			if node.bus == target_bus_name and node.playing:
				node.stop()
		# push children
		for child in node.get_children():
			if child is Node:
				stack.append(child)


func _find_nearest_speaker(max_search_distance: float = 50.0) -> Node:
	# Find nodes that have a 'play_sound' method (your Speaker script) and pick nearest to this trigger.
	var best: Node = null
	var best_dist := max_search_distance
	var root = get_tree().current_scene
	if root == null:
		root = get_tree().root

	var stack: Array = [root]
	while stack.size() > 0:
		var node = stack.pop_back()
		if node is Node and node.has_method("play_sound"):
			var d := global_transform.origin.distance_to(node.global_transform.origin)
			if d < best_dist:
				best_dist = d
				best = node
		for child in node.get_children():
			if child is Node:
				stack.append(child)
	return best
