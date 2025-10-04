extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var checkpoint_spawn: Node3D = $checkpoint_spawn

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player_pawn"):
		print("Checkpoint updated:", checkpoint_spawn.global_transform)
		# Store this checkpoint's spawn as the global respawn point
		Game.last_checkpoint = checkpoint_spawn
