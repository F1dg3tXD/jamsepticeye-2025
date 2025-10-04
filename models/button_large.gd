extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var self_collider: StaticBody3D = $Armature/Skeleton3D/button_large/StaticBody3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self_collider:
		return
	animation_tree.set("parameters/conditions/isPressed", true)
	animation_tree.set("parameters/conditions/!isPressed", false)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == self_collider:
		return
	animation_tree.set("parameters/conditions/isPressed", false)
	animation_tree.set("parameters/conditions/!isPressed", true)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area == area_3d:
		return
	animation_tree.set("parameters/conditions/isPressed", true)
	animation_tree.set("parameters/conditions/!isPressed", false)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area == area_3d:
		return
	animation_tree.set("parameters/conditions/isPressed", false)
	animation_tree.set("parameters/conditions/!isPressed", true)
