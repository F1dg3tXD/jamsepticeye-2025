extends Node3D
class_name ButtonLarge

signal pressed_changed(pressed: bool)

var is_pressed: bool = false:
	set(value):
		if is_pressed == value:
			return
		is_pressed = value
		animation_tree.set("parameters/conditions/isPressed", value)
		animation_tree.set("parameters/conditions/!isPressed", !value)
		emit_signal("pressed_changed", value)
		print("ButtonLarge pressed =", value)

@onready var area_3d: Area3D = $Area3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var self_collider: Node = $Armature/Skeleton3D/button_large/StaticBody3D

# Keep track of overlapping bodies/areas
var overlapping_bodies: Array = []
var overlapping_areas: Array = []

func _ready() -> void:
	animation_tree.set("parameters/conditions/isPressed", is_pressed)
	animation_tree.set("parameters/conditions/!isPressed", !is_pressed)

func _on_area_3d_body_entered(body: Node) -> void:
	if body == self_collider:
		return
	if body not in overlapping_bodies:
		overlapping_bodies.append(body)
	_update_pressed_state()

func _on_area_3d_body_exited(body: Node) -> void:
	if body == self_collider:
		return
	if body in overlapping_bodies:
		overlapping_bodies.erase(body)
	_update_pressed_state()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area == area_3d:
		return
	if area not in overlapping_areas:
		overlapping_areas.append(area)
	_update_pressed_state()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area == area_3d:
		return
	if area in overlapping_areas:
		overlapping_areas.erase(area)
	_update_pressed_state()

func _update_pressed_state() -> void:
	is_pressed = (overlapping_bodies.size() + overlapping_areas.size()) > 0
